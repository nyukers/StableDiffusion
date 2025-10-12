::log file is here \SDComfyUI\ComfyUI\user\comfyui.log
nvidia-smi

@echo off
set Extra=D:\Addon\ExtraModel\extra_model_paths.yaml

for /f %%i in ('powershell -command "Get-Date -Format yyyy-MM-dd"') do set Folder=%%i
echo Today is %Folder%
md D:\outputs\ComfyUI\%Folder%
set Output=D:\outputs\ComfyUI\%Folder%
@echo ...

.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --output-directory %Output% --extra-model-paths-config %Extra%

::%date:yyyy-MM-dd%/Comfyui
::.\python_embeded\python.exe -s ComfyUI\main.py --disable-smart-memory --auto-launch

:: --listen, share webserver ComfyUI to LAN
:: --port 8189, change port to 8189 (8188 default)
:: --force-fp16, for VRAM optimal usage 
:: --disable-smart-memory, for VRAM agressive reusage 
:pause

