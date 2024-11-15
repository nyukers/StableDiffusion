@echo off
:: +update
:python_embeded\python.exe -s SimpleSDXL\entry_with_update.py --language en --models-root ../../SimpleModels --output-path ../../outputs

:: -update
:python_embeded\python.exe -s SimpleSDXL\entry_without_update.py --language en --models-root ../../SimpleModels --output-path ../../outputs
python_embeded\python.exe -s SimpleSDXL\entry_without_update.py --language en --models-root D:\Fooocus\Fooocus\models --output-path D:\Fooocus\Fooocus\outputs

echo All done.
pause