#!/bin/bash

function checkVersion {
    echo "Checking Linux Version ..."

    grep '20.04' /etc/os-release > /dev/null
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

    apt -qq update # || true
    # sleep 120
    
    apt -qq update || true
    sleep 120
    
    apt -qq update || true
    sleep 120
    
    apt install -y $(grep -vE "^\s*#" $ACTUAL_DIR/resources/system/packages.conf  | tr "\n" " ")
}

function installNodeJs {
    echo "Instaling NodeJs ..."
    snap install node --classic
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
    virtualenv ~/venv
    source ~/venv/bin/activate

    git config --global url."https://".insteadOf git://

    echo "Installing python packages from requirements.txt ..."
    pip3 install -U pip setuptools
    pip3 install --no-cache-dir -r $ACTUAL_DIR/resources/system/requirements.txt
}

function installPythonPackages {
    export -f installPythonPackages_LocalUser
    su $LOCAL_USER -c "bash -c installPythonPackages_LocalUser"
}


function installJupyterLabExtensions_LocalUser {
    echo "Installing lab extensions ..."

    source ~/venv/bin/activate

    jupyter labextension install jupyterlab-spreadsheet
    jupyter contrib nbextension install --user
    jupyter nbextensions_configurator enable --user
    jupyter lab build
}

function installJupyterLabExtensions {
    export -f installJupyterLabExtensions_LocalUser
    su $LOCAL_USER -c "bash -c installJupyterLabExtensions_LocalUser"

}

function serviceGlances {
    echo "Config Glances Service ..."

    envsubst < $ACTUAL_DIR/resources/system/start-glances.sh.template  > /usr/local/bin/start-glances.sh
    chmod a+x /usr/local/bin/start-glances.sh
    envsubst < $ACTUAL_DIR/resources/system/glances.service.template  > /etc/systemd/system/glances.service

    systemctl enable glances.service
    systemctl daemon-reload
    systemctl start glances.service
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
    #sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

    /etc/init.d/ssh reload
}
