function llClone() {
    cd ~/src/
    repo_name="$1"
    target_folder="${2:-$repo_name}"  # Use the provided folder argument or default to repo_name
    git clone git@github.com:Lundalogik/"$repo_name".git "$target_folder"
    cd "$target_folder"
}

function npmInstallLatestAndCommit() {
    local args=$(getopt t:s: $*)

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
