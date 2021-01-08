export PIP_REQUIRE_VIRTUALENV=true

alias gpip='PIP_REQUIRE_VIRTUALENV="" pip'

alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias d=docker
alias dc=docker-compose
alias dprune="d system prune --volumes -f"

alias npmOutdated="npm outdated"

function npmInstallLatestAndCommit() {
    local PACKAGE=$1
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

    npm i $PACKAGE@latest && git commit -am "chore(package): update $PACKAGE from v$CURRENT to v$LATEST" && git log -1
}

alias penv="poetry shell"
alias venv=". venv/bin/activate"
alias ldabuild="cd ~/src/lime-dev-app && ./manage.py build-images"
alias ldainit="cd ~/src/lime-dev-app && ./manage.py up --init-app"
alias ldarun="cd ~/src/lime-dev-app && FLASK_ENV=development flask run"
alias ldaupdate="pip uninstall -y lime-core lime-webclient && pip install -r requirements.txt && pip install -e ../lime-webclient/"
alias ldaupdatewithcore="pip uninstall -y lime-core lime-webclient && pip install -r requirements.txt && pip install -e ../lime-core/ && pip install -e ../lime-webclient/"
alias ldarunimport="celery worker --app lime_import.task.app -P solo"

alias awsLogin="aws sso login --profile sharedecr"

alias lint="npm run lint"
alias lintf="npm run lint:fix"
