#!/bin/bash

export ACTUAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export LOCAL_USER="learner"
export LOCAL_PASSWORD="Khhzie7fIx0LXi6r2Jd7"

source $ACTUAL_DIR/functions.sh

echo "Setting up NoSQL box ..."

checkVersion
checkAuthorizedKeys
createSwapMemory
addLocalUser
installSystemPackages
installNodeJs
installPython3.6
installDocker
installPythonPackages
installJupyterLabExtensions
serviceJupyterLab