#!/bin/bash

set -o pipefail -o errtrace -o errexit -o nounset -o functrace

traperror() {
    local el=${1:=??} ec=${2:=??} lc="$BASH_COMMAND"
    errorexit "ERROR in $(basename $0) : $el error $ec : $lc" ${2:=1}
}
trap 'traperror ${LINENO} ${?}' ERR

errorexit() {
    echo >&2 $1
    if [ -z ${2+x} ] ; then
        exit 1
    else
        exit $2
    fi
}

main() {
    if [[ $(id -un) != 'root' ]]; then
          errorexit "must be root" 1
    fi

    echo "ipsum lorem success"
}

main "$@"
