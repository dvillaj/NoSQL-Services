#!/bin/bash

function checkVersion {
    echo "Checking Linux Version ..."

    grep 'Focal Fossa' /etc/os-release > /dev/null
    if [ $? -eq 0 ]
    then
        echo "All good :-)"
    else
        echo "ERROR: This script is intended to run in Ubuntu 20.04 :-("
        exit 1
    fi
}

function checkAuthorizedKeys {
    echo "Checking Authorized Keys  ..."

    if [ -f ~/.ssh/authorized_keys ]; then
        echo "All good :-)"
    else
        echo "ERROR: authorized_keys file not found!"
        exit 1
    fi
}

function createSwapMemory {
    echo "Creating Swap Memory ..."

    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
}

function setupRootUser {
    echo "Setup Root user ..."

    cat $ACTUAL_DIR/resources/system/bashrc >> /root/.bashrc
}


function addLocalUser {
    echo "Adding local user ..."

    useradd -m -s /bin/bash  $LOCAL_USER
    echo $LOCAL_USER:$LOCAL_PASSWORD | chpasswd

    rsync --archive --chown=$LOCAL_USER:$LOCAL_USER $ACTUAL_DIR/resources/localuser/home/ /home/$LOCAL_USER
    rsync --archive --chown=$LOCAL_USER:$LOCAL_USER ~/.ssh /home/$LOCAL_USER

    cat $ACTUAL_DIR/resources/localuser/profile/bashrc >> /home/$LOCAL_USER/.bashrc
   
    usermod -aG sudo $LOCAL_USER
    envsubst < $ACTUAL_DIR/resources/system/sudo.template  > /etc/sudoers.d/local-user

    mkdir -p /opt/compose
    chown $LOCAL_USER:$LOCAL_USER /opt/compose

    su - $LOCAL_USER -c "mkdir ~/notebooks; touch ~/notebooks/.install"
}

function installSystemPackages {
    echo "Installing system packages from packages.conf  ..."

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
# TypeError: namedtuple() got an unexpected keyword argument 'verbose'
function installPython3.6 {
    echo "Instaling python 3.6 ..."

    # http://lavatechtechnology.com/post/install-python-35-36-and-37-on-ubuntu-2004/

    add-apt-repository -y ppa:deadsnakes/ppa
    apt -qq update
    apt install -y python3.6 python3.6-dev

}


function installDocker {
    echo "Installing docker ..."
   
    apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    apt install -qq -y docker-ce docker-compose

    usermod -aG docker $LOCAL_USER
}


function installPythonPackages_LocalUser {
    echo "Creating Virtual Environment ..."
    virtualenv -p /usr/bin/python3.6 ~/venv
    source ~/venv/bin/activate

    echo "Installing python packages from requeriments.txt ..."
    pip install -U pip setuptools
    pip install --no-cache-dir -r $ACTUAL_DIR/resources/system/requeriments.txt
}

function installPythonPackages {
    export -f installPythonPackages_LocalUser
    su $LOCAL_USER -c "bash -c installPythonPackages_LocalUser"
}


function installJupyterLabExtensions_LocalUser {
    echo "Installing lab extensions ..."

    source ~/venv/bin/activate

    jupyter contrib nbextension install --user
    jupyter nbextensions_configurator enable --user
    jupyter lab build
}

function installJupyterLabExtensions {
    export -f installJupyterLabExtensions_LocalUser
    su $LOCAL_USER -c "bash -c installJupyterLabExtensions_LocalUser"

}

function serviceJupyterLab {
    echo "Config Jupyter Lab ..."

    mkdir /etc/jupyter
    envsubst < $ACTUAL_DIR/resources/system/start-jupyter.sh.template  > /usr/local/bin/start-jupyter.sh
    chmod a+x /usr/local/bin/start-jupyter.sh
    envsubst < $ACTUAL_DIR/resources/system/jupyter.service.template  > /etc/systemd/system/jupyter.service

    systemctl enable jupyter.service
    systemctl daemon-reload
    systemctl start jupyter.service
}

function setupFirewall {
    echo "Setting up firewall ..."

    ufw allow OpenSSH
    echo "y" | ufw enable
}

function secureOpenSsh {
    echo "Securing OpenSsh ..."

    sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^UsePAM no/UsePAM yes/' /etc/ssh/sshd_config
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

    /etc/init.d/ssh reload
}
