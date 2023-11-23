export PIP_REQUIRE_VIRTUALENV=true

alias gpip='PIP_REQUIRE_VIRTUALENV="" pip'

alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias d=docker
alias dc=docker-compose
alias dprune="d system prune --volumes -f"

alias npmOutdated="npm outdated"

function llClone() {
    cd ~/src/
    git clone git@github.com:Lundalogik/$1.git
    cd $1
}

function npmInstallLatestAndCommit() {
    local args=`getopt t:s: $*`

    set -- $args

    for i
    do
        case "$i"
        in
            -t)
                local TYPE="$2"; shift;
                shift;;
            -s)
                local SCOPE="$2"; shift;
                shift;;
            --)
                shift;
                local restArgs=("$@");
                shift; break;;
        esac
    done

    local TYPE="${TYPE:-chore}"
    local SCOPE="${SCOPE:-package}"

    # echo TYPE is "${TYPE}"
    # echo SCOPE is "${SCOPE}"

    for PACKAGE in "${restArgs[@]}"
    do
        # echo "${PACKAGE}"
        npmOutdatedOutput=`npm outdated $PACKAGE`

        regex='([0-9]+\.[0-9]+\.[0-9]+)'

        str=$npmOutdatedOutput
        [[ $str =~ $regex ]]
        CURRENT="${BASH_REMATCH[1]}"

        str=${str#*"${BASH_REMATCH[1]}"}
        [[ $str =~ $regex ]]
        WANTED="${BASH_REMATCH[1]}"

        str=${str#*"${BASH_REMATCH[1]}"}
        [[ $str =~ $regex ]]
        LATEST="${BASH_REMATCH[1]}"

        npm i $PACKAGE@latest
        git add package*.json
        git commit -m "${TYPE}(${SCOPE}): update $PACKAGE from v$CURRENT to v$LATEST"
    done
    git log -${#restArgs[@]}
}

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

alias wcinstallbuild="cd ~/src/lime-webclient/ && nvm use && npm i && cd frontend/webclient && npm i && npm run build && cd ../admin && npm i && npm run build && cd ~/src/lime-webclient/"
alias wcinstallbuildall="cd ~/src/lime-webclient/ && nvm use && npm i && cd frontend/importer && nvm use && npm i && npm run build && cd ../webclient && nvm use && npm i && npm run build && cd ../admin && npm i && npm run build && cd ~/src/lime-webclient/"
alias wcupdatepip="poetry run python -m pip install --upgrade pip"
alias wcteardown="cd ~/src/lime-webclient/ && dc down && dprune && rm -rf .venv"
alias buildWC="cd ~/src/lime-webclient/frontend/webclient && npm run build"
alias buildCC="cd ~/src/lime-crm-components && npm run build"
alias buildLE="cd ~/src/lime-elements && npm run build"

alias black="poetry run black . && poetry run isort . --profile=black"
