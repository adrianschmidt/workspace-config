alias gpip='PIP_REQUIRE_VIRTUALENV="" pip'

alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias d=docker
alias dc=docker-compose
alias dprune="d system prune --volumes -f"

alias npmOutdated="with_githubtoken npm outdated"

alias penv="poetry shell"
alias venv=". venv/bin/activate"
alias ldabuild="cd ~/src/lime-dev-app && ./manage.py build-images"
alias ldainit="cd ~/src/lime-dev-app && ./manage.py up --init-app"
alias ldarun="cd ~/src/lime-dev-app && FLASK_ENV=development flask run"
alias ldaupdate="pip uninstall -y lime-core lime-webclient && pip install -r requirements.txt && pip install -e ../lime-webclient/"
alias ldaupdatewithcore="pip uninstall -y lime-core lime-webclient && pip install -r requirements.txt && pip install -e ../lime-core/ && pip install -e ../lime-webclient/"
alias ldarunimport="celery worker --app lime_import.task.app -P solo"

alias wcrun="poetry run flask run"
alias wcrundebug="FLASK_DEBUG=true poetry run flask run"
alias wcrunimport="poetry run celery --app lime_import.task.app worker -P solo"

alias awsLogin="aws sso login --profile sharedecr"

alias lint="npm run lint"
alias lintf="npm run lint:fix"
alias lintpy="poetry run black . && poetry run isort . --profile=black"

alias wcinstallbuild="cd ~/src/lime-webclient/ && nvm use && with_githubtoken npm i && cd frontend/webclient && with_githubtoken npm i && npm run build && cd ../admin && with_githubtoken npm i && npm run build && cd ~/src/lime-webclient/"
alias wcupdatepip="poetry run python -m pip install --upgrade pip"
alias wcteardown="cd ~/src/lime-webclient/ && dc down && dprune && rm -rf .venv"
alias buildWC="cd ~/src/lime-webclient/frontend/webclient && npm run build"
alias buildCC="cd ~/src/lime-crm-components && npm run build"
alias buildLE="cd ~/src/lime-elements && npm run build"
