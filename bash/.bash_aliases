alias ll='grc ls -alFh'
alias la='grc ls -Ah'
alias l='grc ls -CFh'

alias d=docker
alias dc=docker-compose

alias gpg=gpg2

function restart() {
    local SVC=$1

    if [[ -z $SVC ]]; then
        SVC=appserver
    fi

    docker-compose exec $SVC sh -c 'kill `/bin/cat /tmp/uwsgi.pid`'
}

alias restart=restart

function dev-features-on() {
    curl --request PUT --data True http://localhost:8500/v1/kv/config_override/shared/appserver/webclient/use_dev
}

alias dev-features-on=dev-features-on

function dev-features-off() {
    curl --request PUT --data False http://localhost:8500/v1/kv/config_override/shared/appserver/webclient/use_dev
}

alias dev-features-off=dev-features-off

function debug() {
    local SVC=$1
    if [[ -z $SVC ]]; then
        SVC=appserver
    fi
    echo "Running debug with SVC=$SVC..."
    docker-compose stop $SVC
    docker-compose run --service-ports --rm $SVC /lime/debug-service
}

alias debug=debug

function wcbuild() {
    local WD=`pwd`
    cd ~/src/lime-webclient && dc down && make build && cd $WD
}

alias wcbuild=wcbuild

function setup-static-files() {
    local SVC=$1
    if [[ -z $SVC ]]; then
        SVC=appserver
    fi
    docker-compose exec $SVC /lime/setup_static_files.py
}

alias setup-static-files=setup-static-files

alias addDevApp="make add-application DB=~/src/core_54_with_mocked_data.bak"
alias pipWc="dc exec appserver pip install -e /lime/src/lime-webclient --index-url https://pypi.lime.tech:3443/lime/develop/+simple/ && setup-static-files && dev-features-on && restart"
alias fixSQLAlchemy="dc exec appserver pip install SQLAlchemy==1.2.8"
alias fixRuamel="dc exec appserver pip install ruamel.yaml==0.15.41"

function wcsetup() {
    local WD=`pwd`
    cd ~/src/lime-docker && make up && pipWc

    RETRY=0
    until addDevApp; do
        if [ $RETRY -eq 10 ]
        then
            exit 1
        fi
        $(( RETRY++ ))
        sleep 10
    done

    cd $WD
}

alias wcsetup=wcsetup

alias dbash="dc run app bash"

alias pytests="dc run app python3 manage.py test"

function pipinstall() {
    local PKG=$1
    dc run appserver pip install -e src/$PKG
}

alias pipinstall=pipinstall

alias npmOutdated="npm outdated --registry=\"$VERDACCIO\""
