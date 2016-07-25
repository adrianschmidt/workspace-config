./Lundalogik.Mobile.ConsoleHost.exe
-
cmd //C setup && . Python34/Scripts/activate && pip uninstall lime-webclient -y && pip install -e ../lime-webclient
. Python34/Scripts/activate && ./manage.py run
-
cmd //C setup_env.bat && . venv/Scripts/activate
. venv/Scripts/activate && ./manage.py init && cd frontend && source tools/vendor/nodejs/activate && gulp dev:patch && cd ..
-
source tools/vendor/nodejs/activate && gulp build --production && gulp test
source tools/vendor/nodejs/activate && gulp build && gulp watch --no-specs
source tools/vendor/nodejs/activate && gulp test:ui:watch
