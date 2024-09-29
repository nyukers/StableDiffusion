@echo off
nvidia-smi

set PYTHON=
set GIT=
set VENV_DIR=
set A1111_HOME=D:/SDPortable
set VENV_DIR=%A1111_HOME%/venv
set COMMANDLINE_ARGS=--xformers --theme=dark --forge-ref-a1111-home %A1111_HOME% 
::1) --reinstall-torch
::2) --reinstall-xformers

goto 123
@REM Uncomment following code to reference an existing A1111 checkout.
@REM or use parameter --forge-ref-a1111-home %A1111_HOME%

set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% ^
--ckpt-dir %A1111_HOME%/models/Stable-diffusion ^
--hypernetwork-dir %A1111_HOME%/models/hypernetworks ^
--embeddings-dir %A1111_HOME%/embeddings ^
--lora-dir %A1111_HOME%/models/Lora

:123
echo # %COMMANDLINE_ARGS%

call webui.bat
