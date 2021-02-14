#!/bin/bash

export ACTUAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $ACTUAL_DIR/conf.sh
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
#installJupyterLabExtensions
serviceJupyterLab