@Echo off

Title Extra Model Paths Maker by ivo v0.21.0

set yaml=NEW_extra_model_paths.yaml

cd /d %~dp0

if not exist checkpoints (
	Echo.
	Echo [33mWARNING:[0m [92mPlace this file in shared 'models' folder and rerun it.[0m
	Echo.
	Echo Press any key to Exit...&Pause>nul
	goto :eof
)

Echo comfyui:>%yaml%
cd ..\
Echo     base_path: %cd%\>>.\models\%yaml%
cd .\models
Echo     is_default: true>>%yaml%
Echo.>>%yaml%
for /D %%f in (*) do echo     %%f: models\%%f\>>%yaml%
start notepad %yaml%
