alias subl='/c/Program\ Files/Sublime\ Text\ 3/sublime_text.exe'

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias d=docker
alias dc=docker-compose

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

function setup-static-files() {
    local SVC=$1
    if [[ -z $SVC ]]; then
        SVC=appserver
    fi
    docker-compose exec $SVC /lime/setup_static_files.py
}

alias setup-static-files=setup-static-files

function wcbuild() {
    local WD=`pwd`
    cd ~/src/lime-webclient && dc down && make build && cd $WD
}

alias wcbuild=wcbuild

function wcsetup() {
    local WD=`pwd`
    cd ~/src/lime-docker && make purge && make up && make add-application NAME=dev DB='/lime/src/core_54_with_mocked_data.bak' && dc exec appserver pip install -e /lime/src/lime-webclient && setup-static-files && dev-features-on && restart && cd $WD
}

alias wcsetup=wcsetup

alias wcbash="dc run app"

alias pytests="dc run app python3 manage.py test"

function pipinstall() {
    local PKG=$1
    dc run appserver pip install -e src/$PKG
}

alias pipinstall=pipinstall
