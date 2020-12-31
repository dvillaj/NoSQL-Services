#!/bin/bash

export ACTUAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $ACTUAL_DIR/functions.sh

echo "Securing NoSQL box ..."

setupFirewall
secureOpenSsh