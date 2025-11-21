@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM   Universal SageAttention Installer for ComfyUI (Windows)
REM   Safe version with full logging. NO destructive actions.
REM   Place this file inside:  ComfyUI\Addons\
REM ============================================================

:: ===== Initialize Log =====
set "LOGFILE=%~dp0install_sageattention_universal.log"
echo ==== SageAttention Installer Log (%date% %time%) ==== > "%LOGFILE%"
echo Log file: "%LOGFILE%"
echo.

:: ===== Logging Function =====
:log
echo %~1>>"%LOGFILE%"
goto :eof

call :log "=== SCRIPT STARTED ==="

:: ===== Find Python one level up =====
set "PY="
set "PY_CAND=%~dp0..\python.exe;%~dp0..\python_embeded\python.exe;%~dp0..\venv\Scripts\python.exe;%~dp0venv\Scripts\python.exe;python"

for %%P in (%PY_CAND%) do (
    if exist "%%~P" (
        set "PY=%%~P"
        call :log "Python candidate found: %%P"
        goto :found_python
    )
)

echo ERROR: Could not locate python near ComfyUI. See log.
call :log "ERROR: Python not found in any candidate location."
pause
exit /b 1

:found_python
echo Found Python: "%PY%"
call :log "Using Python: %PY%"
echo.

:: ---------- Get environment info -----------
call :log "Collecting environment info via Python..."

"%PY%" - <<END_PY > env_info.tmp 2>>"%LOGFILE%"
import json, sys
info = {"python": f"{sys.version_info.major}.{sys.version_info.minor}"}
try:
    import torch
    info["torch"] = torch.__version__
    info["cuda"] = torch.version.cuda
    info["cuda_available"] = torch.cuda.is_available()
except Exception as e:
    info["torch"] = None
    info["cuda"] = None
    info["cuda_available"] = False
print(json.dumps(info))
END_PY

set /p ENV_JSON=<env_info.tmp
del env_info.tmp >nul

call :log "ENV_JSON raw: %ENV_JSON%"
echo Environment: %ENV_JSON%
echo.

:: ---------- Parse JSON ----------
for /f "tokens=2 delims=:,{}[] " %%A in ("%ENV_JSON%") do set PYVER=%%A
for /f "tokens=4 delims=:,{}[] " %%A in ("%ENV_JSON%") do set TORCHVER=%%A
for /f "tokens=6 delims=:,{}[] " %%A in ("%ENV_JSON%") do set CUDAVER=%%A

echo Python: %PYVER%
echo Torch:  %TORCHVER%
echo CUDA:   %CUDAVER%
echo.

call :log "Parsed Python=%PYVER%, Torch=%TORCHVER%, CUDA=%CUDAVER%"

:: ---------- Normalize Torch and CUDA ----------
set "TORCH_MAJOR="
set "TORCH_MINOR="
if not "%TORCHVER%"=="None" (
    for /f "tokens=1,2 delims=." %%x in ("%TORCHVER%") do (
        set TORCH_MAJOR=%%x
        set TORCH_MINOR=%%y
    )
)

set "CUDA_SHORT="
if not "%CUDAVER%"=="None" (
    for /f "tokens=1,2 delims=." %%x in ("%CUDAVER%") do set CUDA_SHORT=%%x%%y
)

call :log "Normalized: TORCH_MAJOR=%TORCH_MAJOR%, CUDA_SHORT=%CUDA_SHORT%"

:: ---------- Determine install strategy ----------
set "STRATEGY=unknown"

if "%TORCHVER%"=="None" (
    set "STRATEGY=install-torch"
) else (
    if not "%CUDAVER%"=="None" (
        set "STRATEGY=install-sage-gpu"
    ) else (
        set "STRATEGY=install-sage-cpu"
    )
)

echo Strategy: %STRATEGY%
call :log "Strategy selected: %STRATEGY%"
echo.

choice /m "Proceed?" /c YN
if errorlevel 2 (
    call :log "User aborted installation."
    exit /b 0
)

:: ---------- pip wrapper ----------
:run_pip
call :log "Running pip: %*"
"%PY%" -m pip %* >>"%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    call :log "pip FAILED: %*"
    echo ERROR: pip failed. See log.
    exit /b 1
)
call :log "pip OK: %*"
goto :eof

:: ---------- Install Torch if missing ----------
if "%STRATEGY%"=="install-torch" (
    echo Installing CPU Torch...
    call :log "Installing CPU Torch..."
    call :run_pip install torch torchvision torchaudio --no-cache-dir
    set "STRATEGY=install-sage-cpu"
)

:: =====================================================
::              INSTALL SAGEATTENTION (CPU)
:: =====================================================
if "%STRATEGY%"=="install-sage-cpu" (
    echo Installing SageAttention (CPU fallback)...
    call :log "Installing SageAttention CPU fallback..."
    call :run_pip install sage-attention --no-cache-dir
    goto :post_install
)

:: =====================================================
::              INSTALL SAGEATTENTION (GPU)
:: =====================================================
set "SAGE_OK=0"
set "SAGE_VERSIONS=2.2.0 2.3.0"
set "SOURCES1=https://github.com/woct0rdho/SageAttention/releases/download"
set "SOURCES2=https://github.com/sdbds/SageAttention-for-windows/releases/download"
set "AI=https://github.com/wildminder/AI-windows-whl/releases/download"

if "%STRATEGY%"=="install-sage-gpu" (
    echo Trying GPU SageAttention wheels...
    call :log "Trying GPU SageAttention wheels..."

    for %%V in (%SAGE_VERSIONS%) do (
        set "W1=%SOURCES1%/v%%V/sageattention-%%V+cu%CUDA_SHORT%torch%TORCH_MAJOR%.post3-cp39-abi3-win_amd64.whl"
        set "W2=%SOURCES2%/v%%V/sageattention-%%V+cu%CUDA_SHORT%torch%TORCH_MAJOR%.post3-cp39-abi3-win_amd64.whl"
        set "W3=%AI%/v%%V/sageattention-%%V+cu%CUDA_SHORT%torch%TORCH_MAJOR%.post3-cp39-abi3-win_amd64.whl"

        for %%W in ("!W1!" "!W2!" "!W3!") do (
            echo Trying %%~W
            call :log "Trying %%~W"
            call :run_pip install %%~W --no-cache-dir 2>nul

            "%PY%" - <<END_IMP > tmp_check.txt 2>>"%LOGFILE%"
try:
    import sage_attention
    print("OK")
except:
    print("NO")
END_IMP

            set /p CHK=<tmp_check.txt
            del tmp_check.txt

            call :log "Import result: %CHK%"

            if "%CHK%"=="OK" (
                set "SAGE_OK=1"
                goto :gpu_done
            )
        )
    )
)

:gpu_done
if "%SAGE_OK%"=="1" (
    echo SageAttention installed (GPU).
    call :log "GPU wheel installed successfully."
) else (
    echo GPU wheels not found. Installing CPU alternative...
    call :log "GPU wheels NOT found. Fallback to CPU pip install."
    call :run_pip install sage-attention --no-cache-dir
)

:: =====================================================
::                   POST INSTALL CHECK
:: =====================================================
:post_install
echo Running import test...
call :log "Running import test..."

"%PY%" - <<END_POST > post.txt 2>&1
try:
    import sage_attention
    print("SAGE_OK")
except Exception as e:
    print("SAGE_FAIL", e)
END_POST

set /p PC=<post.txt
del post.txt

echo Result: %PC%
call :log "Post-install result: %PC%"

:: =====================================================
::         Optional Triton installation
:: =====================================================
choice /m "Install Triton (optional)?" /c YN
if errorlevel 2 goto skip_triton
call :log "User selected Triton install."
call :run_pip install triton-windows==3.4.0.post20
:skip_triton

:: =====================================================
::         Optional FlashAttention installation
:: =====================================================
choice /m "Install FlashAttention (optional)?" /c YN
if errorlevel 2 goto skip_flash
call :log "User selected FlashAttention install."

for %%F in (
    https://github.com/bdashore3/flash-attention/releases/download/v0.5.3/flash_attn-0.5.3-cp39-cp39-win_amd64.whl
    https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.4.0/flash_attn-0.4.0-cp39-cp39-win_amd64.whl
) do (
    call :log "Trying FlashAttention wheel: %%F"
    call :run_pip install %%F --no-cache-dir
)
:skip_flash

:: =====================================================
::             Create launcher
:: =====================================================
echo Creating launcher...
call :log "Creating launcher run_sageattention.bat"

(
  echo @echo off
  echo cd /d "%~dp0\.."
  echo "%PY%" ComfyUI\main.py --use-sage-attention
  echo pause
) > "%~dp0..\run_sageattention.bat"

call :log "Launcher created."

echo.
echo Installation complete.
echo See full log here:
echo   %LOGFILE%

call :log "=== INSTALLATION COMPLETE ==="
pause
exit /b 0
