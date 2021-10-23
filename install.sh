#!/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

export ACTUAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export TERM=vt100

source $ACTUAL_DIR/conf.sh
source $ACTUAL_DIR/functions.sh

echo "Setting up NoSQL box ..."

checkVersion
checkAuthorizedKeys
createSwapMemory
setupRootUser
addLocalUser
installSystemPackages
installNodeJs
installDocker
installPythonPackages
installJupyterLabExtensions
serviceJupyterLab