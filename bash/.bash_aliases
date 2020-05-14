export PIP_REQUIRE_VIRTUALENV=true

alias gpip='PIP_REQUIRE_VIRTUALENV="" pip'

alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias d=docker
alias dc=docker-compose
alias dprune="d system prune --volumes -f"

alias npmOutdated="npm outdated"

function ldavenv() {
    local WD=`pwd`
    cd ~/src/lime-dev-app && . venv/bin/activate
    cd $WD
}

alias ldavenv="ldavenv"
alias ldabuild="cd ~/src/lime-dev-app && ./manage.py build-images"
alias ldainit="cd ~/src/lime-dev-app && ./manage.py up --init-app"
alias ldarun="cd ~/src/lime-dev-app && FLASK_ENV=development flask run"
alias ldaupdate="pip uninstall -y lime-core lime-webclient && pip install -r requirements.txt && pip install -e ../lime-webclient/"

alias awsLogin="~/src/lime-dev-app/aws-login.sh"

alias lint="npm run lint"
alias lintf="npm run lint:fix"
