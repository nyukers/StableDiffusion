del comfyui.old /Q
rename comfyui.log comfyui.old

@echo off
call cd D:\SDPortable\venv\Scripts
echo %cd%
call activate.bat
echo VEnv activated Ok!
call cd D:\SDComfyUI
echo %cd%
echo disable-smart-memory activated!
call .\python_embeded\python.exe -s ComfyUI\main.py --disable-smart-memory
pause

