del comfyui.old /Q
rename comfyui.log comfyui.old
::set path

nvidia-smi
:.\python_embeded\Scripts\comfycli.exe --version

.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --force-fp16

:: default port 8188, you can change this by param as "--port 8189"
:: --force-fp16 for GPU RAM optimal usage 
:pause
