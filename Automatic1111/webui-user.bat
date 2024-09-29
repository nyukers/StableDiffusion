@echo off
::if not exist python (echo Unpacking Git and Python... & mkdir tmp & start /wait git_python.part01.exe & del git_python.part01.exe & del git_python.part*.rar)
set pypath=home = %~dp0python
::if exist venv (powershell -command "$text = (gc venv\pyvenv.cfg) -replace 'home = .*', $env:pypath; $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False);[System.IO.File]::WriteAllLines('venv\pyvenv.cfg', $text, $Utf8NoBomEncoding);")

nvidia-smi.exe
echo # Cleaning cache: tmp\tmp, tmp\pip, tmp\gradio, pip\cache ####################################################
for /d %%i in (tmp\tmp*,tmp\pip*,tmp\gradio\*) do rd /s /q "%%i" 2>nul || ("%%i" && exit /b 1) & del /q tmp\tmp* > nul 2>&1 & rd /s /q pip\cache 2>nul
echo # Cleaning Ok

set APPDATA=tmp
set USERPROFILE=tmp
set TEMP=tmp
set PYTHON=python\python.exe
set GIT=git\cmd\git.exe
set PATH=git\cmd;c:\ffmpeg\bin;
set VENV_DIR=venv

:: Vars original
set TF_ENABLE_ONEDNN_OPTS=0
set SAFETENSORS_FAST_GPU=1
set COMMANDLINE_ARGS=--xformers --autolaunch --theme=dark --disable-safe-unpickle --disable-nan-check --precision full --no-half --upcast-sampling --styles-file="styles\*.csv"
::x) --skip-version-check
::1) --reinstall-torch
::2) --reinstall-xformers

:: a) --skip-load-model-at-start for skip load model at startup???
:: b) --disable-safe-unpickle for DeOldify and AnimateDiff exts (ckpt models)
:: c) --no-half-vae --no-half OR --disable-nan-check for NansException is tensor with all NaNs was produced in VAE 
:: d) --api for API plugin external application: GIMP, Krita
:: e) --listen for web users from LAN
:: f) --log-startup for more details to console
:: g) --precision full --no-half FOR prevention black image. Maybe remove --disable-nan-check ???
:: h) --share Use share=True for gradio and make the UI accessible through their site.

:: Vars by Orex
::set CUDA_MODULE_LOADING=LAZY 
::set NUMEXPR_MAX_THREADS=8
::set PYTORCH_CUDA_ALLOC_CONF=garbage_collection_threshold:0.9,max_split_size_mb:512
::set COMMANDLINE_ARGS=--autolaunch --theme=dark --disable-safe-unpickle --xformers --opt-channelslast --skip-load-model-at-start

::set path
::set temp
echo # VARS %PATH% AND %TEMP% Ok
::ffmpeg.exe
echo # FFmpeg Ok

echo # Run Web UI with args ###################################################
echo # %COMMANDLINE_ARGS%
::git pull origin master
::echo # A1111 Update Ok
::pause
call webui.bat
