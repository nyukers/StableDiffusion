@echo off
setlocal enabledelayedexpansion

echo ===============================
echo SageAttention Environment Analyzer (BAT version)
echo This script is 100%% safe: it does NOT install anything.
echo ===============================
echo.

:: ----------- DETECT PYTHON -----------
set "PY="
for %%P in (
    "%~dp0..\python.exe"
    "%~dp0..\python_embeded\python.exe"
    "%~dp0..\venv\Scripts\python.exe"
    "%~dp0venv\Scripts\python.exe"
    "python"
) do (
    if exist %%~P (
        set "PY=%%~P"
        goto :found_py
    )
)

echo ERROR: Python not found near ComfyUI or in PATH.
echo Put this script inside Addons\ or run in the correct environment.
pause
exit /b 1

:found_py
echo Found Python: "%PY%"
echo.

:: ---------- GET ENV INFO ----------
echo Gathering info from Python...

"%PY%" - <<END_PY > env_info.tmp
import json, sys
info = {
    "python": f"{sys.version_info.major}.{sys.version_info.minor}",
}
try:
    import torch
    info["torch"] = torch.__version__
    info["cuda_ver"] = torch.version.cuda
    info["cuda_available"] = torch.cuda.is_available()
except Exception as e:
    info["torch"] = None
    info["cuda_ver"] = None
    info["cuda_available"] = False

print(json.dumps(info))
END_PY

set /p ENV_JSON=<env_info.tmp
del env_info.tmp >nul 2>&1

echo Raw data: %ENV_JSON%
echo.

:: ---------- PARSE JSON ----------
for /f "tokens=2 delims=:," %%a in ("%ENV_JSON%") do set PYVER=%%a

for /f "tokens=4 delims=:," %%a in ("%ENV_JSON%") do set TORCHVER=%%a

for /f "tokens=6 delims=:," %%a in ("%ENV_JSON%") do set CUDAVER=%%a

echo ---------------------------------
echo Python version: %PYVER%
echo Torch version:  %TORCHVER%
echo CUDA version:   %CUDAVER%
echo ---------------------------------
echo.

echo NOTE:
echo   If torch=None or cuda=None, GPU wheels of SageAttention will NOT work.
echo.

pause
exit /b 0
