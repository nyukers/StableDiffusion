@echo off
nvidia-smi

set PYTHON=
set GIT=
set VENV_DIR=
set MODEL_HOME=D:/models
set A1111_HOME=D:/SDPortable
set VENV_DIR=%A1111_HOME%/venv
:: set HF_HUB_OFFLINE=True
:: set XFORMERS_MORE_DETAILS=1

set COMMANDLINE_ARGS=--xformers --theme=dark --styles-file="D:\Addon\Styles\*.csv" --cuda-malloc
::--forge-ref-a1111-home %A1111_HOME% 
::--cuda-malloc --cuda-stream 

set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% ^
--ckpt-dir %MODEL_HOME%/Stable-diffusion ^
--hypernetwork-dir %MODEL_HOME%/hypernetworks ^
--embeddings-dir %MODEL_HOME%/embeddings ^
--lora-dir %MODEL_HOME%/Lora ^
--vae-dir %MODEL_HOME%/vae

echo # %COMMANDLINE_ARGS%

call webui.bat
