@echo off
setlocal

:: ============================================================================
:: AI Environment Setup Toolkit (v1.1 - Streamlined Flow)
:: ============================================================================
:: This version improves the logic in Step 4 to avoid an unnecessary
:: restart if the CUDA Toolkit is already installed, creating a smoother flow.
:: ============================================================================

:: Use an absolute path for the venv directory
set "VENV_DIR=%cd%\.venv"
set "PROGRESS_FILE=install_progress.txt"

:: --- Script Start ---
cls
echo #############################################################
echo ##      AI Environment Setup Toolkit (v12.5)               ##
echo #############################################################
echo.

if not exist "%PROGRESS_FILE%" (
    echo Starting new installation...
    goto :STEP0
)

set /p CURRENT_STEP=<%PROGRESS_FILE%
echo Resuming installation from %CURRENT_STEP%...
goto %CURRENT_STEP%


:STEP0
echo.
echo --- [Step 0: GPU Driver Check] ---
echo Checking for NVIDIA GPU and drivers...
nvidia-smi
if %errorlevel% equ 0 (goto :STEP0_SUCCESS) else (goto :STEP0_FAIL)

:STEP0_FAIL
echo.
echo ERROR: 'nvidia-smi' command failed.
echo Please ensure you have an NVIDIA GPU and that the latest drivers are installed.
pause
exit /b

:STEP0_SUCCESS
echo.
echo 'nvidia-smi' executed successfully.
echo.
pause
echo STEP1>%PROGRESS_FILE%
goto :STEP1


:STEP1
echo.
echo --- [Step 1: Create Virtual Environment] ---
if exist "%VENV_DIR%" (
    echo Virtual environment already exists. Skipping creation.
) else (
    echo Creating Python virtual environment...
    python -m venv "%VENV_DIR%"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create virtual environment.
        pause
        exit /b
    )
    echo Virtual environment created successfully.
)
echo.
pause
echo STEP2>%PROGRESS_FILE%
goto :STEP2


:STEP2
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 2: Check Python Version] ---
echo Checking Python version...
python --version
echo.
echo It is recommended to use Python 3.10 or 3.11 for best compatibility.
echo.
pause
echo STEP3>%PROGRESS_FILE%
goto :STEP3


:STEP3
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 3: Check for Visual Studio Build Tools] ---

set "VSWHERE_PATH=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE_PATH%" goto :VS_NOT_FOUND

echo Checking for existing Visual Studio installation...
set "VSWORKLOAD=Microsoft.VisualStudio.Workload.NativeDesktop"
"%VSWHERE_PATH%" -requires %VSWORKLOAD% -property installationPath >nul 2>&1
if %errorlevel% equ 0 goto :VS_FOUND

:VS_NOT_FOUND
echo.
echo C++ Build Tools were not found. They are required.
echo Please download and install "Build Tools for Visual Studio 2022".
echo Make sure to select the "Desktop development with C++" workload during installation.
echo Link: https://visualstudio.microsoft.com/visual-cpp-build-tools/
echo.
echo After installation, please CLOSE this window and run this script again.
echo.
pause
echo STEP4>%PROGRESS_FILE%
exit /b

:VS_FOUND
echo.
echo Found a compatible Visual Studio installation. Skipping.
echo.
pause
echo STEP4>%PROGRESS_FILE%
goto :STEP4


:STEP4
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 4: Check for NVIDIA CUDA Toolkit] ---
echo Checking for existing CUDA Toolkit installation...

nvcc --version >nul 2>&1
if %errorlevel% equ 0 (goto :CUDA_FOUND) else (goto :CUDA_NOT_FOUND)

:CUDA_NOT_FOUND
echo.
echo CUDA Toolkit not found.
echo Please download and install a compatible version from the official archive:
echo https://developer.nvidia.com/cuda-toolkit-archive
echo.
echo After installation is complete, you MUST restart this script.
pause
exit /b

:CUDA_FOUND
:: FIX: If CUDA is found, just proceed to the next step without exiting.
echo Found existing CUDA Toolkit installation:
nvcc --version
echo.
echo CUDA Toolkit check passed. Proceeding to the next step...
echo.
pause
echo STEP5>%PROGRESS_FILE%
goto :STEP5


:STEP5
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 5: Upgrade Pip] ---
echo Upgrading Python packaging tools...
python -m pip install --upgrade pip setuptools wheel
echo.
pause
echo STEP6>%PROGRESS_FILE%
goto :STEP6


:STEP6
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 6: Install PyTorch] ---
echo Checking for existing PyTorch installation...

:: FIX: Check if PyTorch is already installed.
pip show torch >nul 2>&1
if %errorlevel% equ 0 (goto :PYTORCH_FOUND) else (goto :PYTORCH_NOT_FOUND)

:PYTORCH_FOUND
echo.
echo PyTorch is already installed. Skipping this step.
echo Installed version details:
pip show torch
echo.
pause
echo STEP7>%PROGRESS_FILE%
goto :STEP7

:PYTORCH_NOT_FOUND
echo.
echo PyTorch not found. Proceeding with installation guidance...
echo Detecting system information...

set "PYTHON_VERSION=Not Detected"
for /f "tokens=2" %%p in ('python --version 2^>^&1') do set "PYTHON_VERSION=%%p"
set "OS_TYPE=Windows"
set "CUDA_VERSION=Not Detected"
for /f "tokens=5" %%a in ('nvcc --version ^| findstr "release"') do (
    set "CUDA_VERSION_RAW=%%a"
)
if defined CUDA_VERSION_RAW (
    set "CUDA_VERSION=%CUDA_VERSION_RAW:,=%"
)

cls
echo ######################################################################
echo ##                  ACTION REQUIRED: Get PyTorch Command            ##
echo ######################################################################
echo.
echo Your system configuration has been detected. Use this information
echo to select the correct options on the PyTorch website.
echo.
echo ======================= YOUR CONFIGURATION =======================
echo.
echo   - Your Python Version:  %PYTHON_VERSION%
echo   - Your Operating System: %OS_TYPE%
echo   - Your CUDA Version:    %CUDA_VERSION%
echo.
echo ==================================================================
echo.
echo INSTRUCTIONS:
echo.
echo 1. Open your web browser and go to: https://pytorch.org/get-started/locally/
echo.
echo 2. On the website, select the options that match your configuration above.
echo.
if "%CUDA_VERSION%"=="Not Detected" (
    echo    - Compute Platform:   CPU (CUDA was not found on your system)
) else (
    echo    - Compute Platform:   %CUDA_VERSION% (Select the closest compatible option)
)
echo.
echo 3. Copy the ENTIRE command (it starts with "pip3 install...").
echo.

:PYTORCH_MANUAL_INPUT
echo.
set /p "PYTORCH_COMMAND=Paste the command from the PyTorch website here and press Enter: "

echo "%PYTORCH_COMMAND%" | findstr /R /C:"^.*pip. install torch.*$" >nul
if %errorlevel% neq 0 (
    echo.
    echo ERROR: That does not look like a valid PyTorch install command.
    echo Please try copying it from the website again.
    goto :PYTORCH_MANUAL_INPUT
)
echo.
echo Installing PyTorch...
%PYTORCH_COMMAND%
if %errorlevel% neq 0 (
    echo ERROR: PyTorch installation failed.
    pause
    goto :PYTORCH_MANUAL_INPUT
)
echo PyTorch installed successfully.
echo.
pause
echo STEP7>%PROGRESS_FILE%
goto :STEP7


:STEP7
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 7: Install Triton] ---
pip install -U "triton-windows<3.5"
if %errorlevel% neq 0 (
    echo ERROR: Triton installation failed.
    pause
    exit /b
)
echo Triton installed successfully.
echo.
pause
echo STEP8>%PROGRESS_FILE%
goto :STEP8


:STEP8
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 8: Install Attention Libraries] ---
echo Checking for existing Attention library installations...

set "SAGE_FOUND=0"
set "FLASH_FOUND=0"
pip show sageattention >nul 2>&1
if %errorlevel% equ 0 set "SAGE_FOUND=1"
pip show flash-attn >nul 2>&1
if %errorlevel% equ 0 set "FLASH_FOUND=1"

if "%SAGE_FOUND%"=="1" if "%FLASH_FOUND%"=="1" (
    echo.
    echo SageAttention and FlashAttention are already installed. Skipping this step.
    echo.
    pause
    echo STEP9>%PROGRESS_FILE%
    goto :STEP9
)

echo.
echo One or both attention libraries are missing. Proceeding with installation guidance...
echo Detecting your environment for wheel files...

set "PYTHON_VERSION=Not Detected"
set "PYTHON_TAG=unknown"
for /f "tokens=2" %%p in ('python --version 2^>^&1') do set "PYTHON_VERSION=%%p"
if not "%PYTHON_VERSION%"=="Not Detected" (
    for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do set "PYTHON_TAG=cp%%a%%b"
)
set "CUDA_VERSION=Not Detected"
set "CUDA_TAG=unknown"
for /f "tokens=5" %%a in ('nvcc --version ^| findstr "release"') do set "CUDA_VERSION_RAW=%%a"
if defined CUDA_VERSION_RAW (
    set "CUDA_VERSION=%CUDA_VERSION_RAW:,=%"
    set "CUDA_TAG_TEMP=%CUDA_VERSION:.=%"
    set "CUDA_TAG=cu%CUDA_TAG_TEMP%"
)
set "PYTORCH_VERSION=Not Detected"
set "PYTORCH_TAG=unknown"
for /f "delims=" %%v in ('python -c "import torch; print(torch.__version__)" 2^>^&1') do set "PYTORCH_VERSION=%%v"
if not "%PYTORCH_VERSION%"=="Not Detected" (
    set "PYTORCH_CLEAN_VER=%PYTORCH_VERSION:+= %"
    for /f "tokens=1" %%a in ("%PYTORCH_CLEAN_VER%") do set "PYTORCH_BASE_VER=%%a"
    for /f "tokens=1,2 delims=." %%a in ("%PYTORCH_BASE_VER%") do set "PYTORCH_TAG=torch%%a.%%b"
)

cls
echo ######################################################################
echo ##             ACTION REQUIRED: Download Attention Wheels           ##
echo ######################################################################
echo.
echo ================= YOUR WHEEL FILE TAGS =================
echo.
echo   - Python Tag:  %PYTHON_TAG%  (from Python %PYTHON_VERSION%)
echo   - CUDA Tag:    %CUDA_TAG%  (from CUDA %CUDA_VERSION%)
echo   - PyTorch Tag: %PYTORCH_TAG% (from PyTorch %PYTORCH_VERSION%)
echo.
echo ==========================================================
echo.
echo INSTRUCTIONS:
echo.
echo 1. Open these two links:
echo    - SageAttention:  https://github.com/sdbds/SageAttention-for-windows/releases OR https://github.com/woct0rdho/SageAttention/releases
echo    - FlashAttention: https://github.com/bdashore3/flash-attention/releases OR https://github.com/mjun0812/flash-attention-prebuild-wheels
echo    - Other Source: https://github.com/wildminder/AI-windows-whl
echo.
echo 2. On each page, find the .whl file that CONTAINS ALL THREE of your tags.
echo.
echo 3. Download the two matching .whl files into this folder: %cd%
echo.
pause
echo.
set /p "SAGE_WHEEL_PATH=Enter the full name of the SageAttention wheel file: "
set /p "FLASH_WHEEL_PATH=Enter the full name of the FlashAttention wheel file: "

if not exist "%SAGE_WHEEL_PATH%" (
    echo ERROR: SageAttention file not found.
    pause
    exit /b
)
pip install "%SAGE_WHEEL_PATH%"
if %errorlevel% neq 0 (
    echo ERROR: SageAttention installation failed.
    pause
    exit /b
)
if not exist "%FLASH_WHEEL_PATH%" (
    echo ERROR: FlashAttention file not found.
    pause
    exit /b
)
pip install "%FLASH_WHEEL_PATH%"
if %errorlevel% neq 0 (
    echo ERROR: FlashAttention installation failed.
    pause
    exit /b
)
echo Attention libraries installed successfully.
echo.
pause
echo STEP9>%PROGRESS_FILE%
goto :STEP9


:STEP9
call "%VENV_DIR%\Scripts\activate.bat"
echo.
echo --- [Step 9: Final Verification] ---
echo Running final checks...
echo.

:: FIX: This is the most important check for the user.
echo Verifying PyTorch and CUDA runtime...
python -c "import torch; print(f'PyTorch version: {torch.__version__}'); assert torch.cuda.is_available(), 'PyTorch reports CUDA is NOT available!'; print('PyTorch CUDA check: OK')"
if %errorlevel% neq 0 (
    echo ERROR: PyTorch CUDA runtime check failed. The installation will not work.
    pause
    exit /b
)
echo.

:: FIX: Verify package installation using pip show, which is more reliable than import.
echo Verifying dependent packages are installed...
set "VERIFICATION_FAILED=0"

pip show triton-windows >nul 2>&1
if %errorlevel% neq 0 (
    echo   - ERROR: triton-windows is not installed.
    set "VERIFICATION_FAILED=1"
) else (
    echo   - Triton installation: OK
)

pip show sageattention >nul 2>&1
if %errorlevel% neq 0 (
    echo   - ERROR: sageattention is not installed.
    set "VERIFICATION_FAILED=1"
) else (
    echo   - SageAttention installation: OK
)

pip show flash-attn >nul 2>&1
if %errorlevel% neq 0 (
    echo   - ERROR: flash-attn is not installed.
    set "VERIFICATION_FAILED=1"
) else (
    echo   - FlashAttention installation: OK
)

echo.
if "%VERIFICATION_FAILED%"=="1" (
    echo ERROR: The final verification failed. Please review the errors above.
    pause
    exit /b
)

echo.
echo ==========================================================
echo               INSTALLATION COMPLETE!
echo ==========================================================
echo.
echo Your environment is ready. To use it, open a new command
echo prompt and run: %VENV_DIR%\Scripts\activate
echo.

del %PROGRESS_FILE%
pause

goto :EOF

