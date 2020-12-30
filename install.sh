#!/bin/bash

ACTUAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOCAL_USER="learner"


function addLocalUser {
    echo "Adding learning user ..."

    useradd -m -s /bin/bash  $LOCAL_USER
    echo $LOCAL_USER:$LOCAL_USER | chpasswd
    usermod -aG sudo $LOCAL_USER

    rsync --archive --chown=$LOCAL_USER:$LOCAL_USER $ACTUAL_DIR/resources/localuser/ /home/$LOCAL_USER
    chmod +x /home/$LOCAL_USER/*.sh

    rsync --archive --chown=$LOCAL_USER:$LOCAL_USER ~/.ssh /home/learnel

    mkdir -p /opt/compose
    chown $LOCAL_USER:$LOCAL_USER /opt/compose

    su - $LOCAL_USER -c "mkdir ~/notebooks; touch ~/notebooks/.install"
}

function installSystemPackages {
    echo "Instaling system packages from packages.conf  ..."

    apt -qq update
    apt install -y $(grep -vE "^\s*#" $ACTUAL_DIR/resources/system/packages.conf  | tr "\n" " ")
}

function installNodeJs {
    echo "Instaling NodeJs"

    curl -sL https://deb.nodesource.com/setup_14.x -o ~/nodesource_setup.sh
    bash ~/nodesource_setup.sh
    apt install -y nodejs
    rm ~/nodesource_setup.sh
}

# Python 3.6 is needed for riak python library
function installPython3.6 {
    echo "Instaling python 3.6 ..."

    # http://lavatechtechnology.com/post/install-python-35-36-and-37-on-ubuntu-2004/

    add-apt-repository -y ppa:deadsnakes/ppa
    apt -qq update
    apt install -y python3.6 python3.6-dev

    su - $LOCAL_USER -c "virtualenv -p /usr/bin/python3.6 ~/venv"
}


function installDocker {
    echo "Installing docker ..."

    
    apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    apt install -qq -y docker-ce

    echo "Installing docker compose ..."

    curl -sL https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    usermod -aG docker $LOCAL_USER
}


function installPythonPackages {
    echo "Instaling python packages from requeriments.txt ..."

    su $LOCAL_USER -c "source ~/venv/bin/activate;  pip install -r resources/system/requeriments.txt"
}


function installJupyterLabExtensions_LocalUser {
    echo "Installing lab extensions ..."

    source ~/venv/bin/activate

    # export jupyter notebooks with images embebed
    # Version 0.5.1 
    pip install jupyter_contrib_nbextensions
    jupyter contrib nbextension install --user

    pip install jupyter_nbextensions_configurator
    jupyter nbextensions_configurator enable --user


    echo "Git Client"
    pip install jupyterlab-git
    jupyter lab build

    echo "Table of Contents"
    jupyter labextension install @jupyterlab/toc

    echo "Drawio"
    jupyter labextension install jupyterlab-drawio

    echo "Variable Inspector"
    jupyter labextension install @lckr/jupyterlab_variableinspector
}

function installJupyterLabExtensions {
    export -f installJupyterLabExtensions_LocalUser
    su $LOCAL_USER -c "bash -c installJupyterLabExtensions_LocalUser"
}

function serviceJupyterLab {
    echo "Config Jupyter Lab ..."

    mkdir /etc/jupyter
    cp resources/system/start-jupyter.sh /usr/local/bin
    chmod a+x /usr/local/bin/start-jupyter.sh
    cp resources/system/jupyter.service /etc/systemd/system/

    systemctl enable jupyter.service
    systemctl daemon-reload
    systemctl start jupyter.service
}

function checkVersion {
    echo "Checking Linux Version ..."

    grep 'Focal Fossa' /etc/os-release > /dev/null
    if [ $? -eq 0 ]
    then
        echo "All good :-)"
    else
        echo "This script is intended to run in Ubuntu 20.04 :-("
        exit 1
    fi
}

function setupFirewall {
    ## First Steps
    echo "Enabling Firewall ..."

    ufw allow OpenSSH
    echo "y" | sudo ufw enable
}

echo "Setting up NoSQL box ..."


checkVersion
setupFirewall
addLocalUser
installSystemPackages
installNodeJs
installPython3.6
installDocker
installPythonPackages
installJupyterLabExtensions
serviceJupyterLab