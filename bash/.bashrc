alias subl='/c/Program\ Files/Sublime\ Text\ 3/sublime_text.exe'

alias d=docker
alias dc=docker-compose

alias wcsetup="make up && make add-application NAME=dev DB='/lime/src/core54.bak' && make init-webclient && make pip-install-webclient && make setup-static-files && make feature-flags-on && make restart-appserver"
