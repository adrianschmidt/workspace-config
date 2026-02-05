alias gpip='PIP_REQUIRE_VIRTUALENV="" pip'

alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias "c."="cursor ."

alias d=docker
alias dc="docker compose"
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

alias wcrun="poetry run lime-webserver -x .lime/extra.py run dev"
alias wcrunold="poetry run flask run"
alias wcrundebug="FLASK_DEBUG=true poetry run flask run"
alias wcrunimport="poetry run celery --app lime_import.task.app worker -P solo"

alias awsLogin="aws sso login --profile sharedecr"
alias bedrockLogin="aws sso login --profile bedrock-dev"
alias bedrockAPI="cd ~/src/aws-bedrock-gateway && npm run start-api"
alias bedrockGateway="cd ~/src/aws-bedrock-gateway && NODE_TLS_REJECT_UNAUTHORIZED=0 AWS_PROFILE=bedrock-dev npm run ws:dev"

alias lint="npm run lint"
alias lintf="npm run lint:fix"
alias lintpy="poetry run black . && poetry run isort . --profile=black && poetry run flake8 ."
alias lintruff="poetry run ruff format && poetry run ruff check --fix && poetry run ruff format"

alias wcinstallbuild="cd ~/src/lime-webclient/ && with_githubtoken npm i && cd frontend/webclient && with_githubtoken npm i && npm run build && cd ../service-worker && with_githubtoken npm i && npm run build && cd ../admin && with_githubtoken npm i && npm run build && cd ../new-admin && with_githubtoken npm i && npm run build && cd ~/src/lime-webclient/"
alias wcsetup="pipx upgrade lime-project && wcinstallbuild && wcteardown && lime-project env prepare"

alias wcupdatepip="poetry run python -m pip install --upgrade pip"
alias wcteardown="dc down && dprune && rm -rf .venv"
alias wceventhandler="poetry run python .venv/bin/lime-event-handler"
alias wctaskhandler="poetry run python .venv/bin/lime-task-handler"

alias run_bedrock_gateway="cd ~/src/aws-bedrock-gateway && npm run start-api -- --profile bedrock-dev"

alias nibb="npm i && npm run build && npm run build"

alias yrn="with_npmtoken with_githubtoken yarn" # Seriously, yarn can't even run `yarn -h` without these tokens 🤦‍♂️

# Autogen related aliases

alias agStart='cd ~/src/autogen && with_openai_api_key with_anthropic_api_key docker-compose up -d'
alias agStop='cd ~/src/autogen && docker-compose down'
alias agLogs='cd ~/src/autogen && docker-compose logs -f'
alias agShell='cd ~/src/autogen && with_openai_api_key with_anthropic_api_key docker-compose exec autogen /bin/bash'
alias agJupyter='cd ~/src/autogen && with_openai_api_key with_anthropic_api_key docker-compose exec autogen jupyter notebook --ip=0.0.0.0 --allow-root'
alias agPipUpdate='cd ~/src/autogen && docker-compose exec autogen pip install --no-cache-dir --upgrade'
alias agHaikuProxyStart='cd ~/src/autogen && with_anthropic_api_key docker-compose exec autogen litellm --model claude-3-haiku-20240307'
alias agSonnetProxyStart='cd ~/src/autogen && with_anthropic_api_key docker-compose exec autogen litellm --model claude-3-sonnet-20240229 --port 4001'
alias agOpusProxyStart='cd ~/src/autogen && with_anthropic_api_key docker-compose exec autogen litellm --model claude-3-opus-20240229 --port 4002'

# OpenClaw related aliases

alias ocRestartGateway='./docker-paranoid.sh down && ./docker-paranoid.sh up'
alias ocRestartSandbox='docker stop $(docker ps --filter "name=sbx" -q) 2>/dev/null ./docker-paranoid.sh down && ./docker-paranoid.sh up'
