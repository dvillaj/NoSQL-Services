#!/bin/bash

ping -c 1 www.google.es > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: No Internet connection."
    exit 2
fi

while [ ! -f ~/notebooks/.install -a  "$1" != "-f" ]; do
    read -p "This process downloads the latest version of the notebooks (deleting the current ones). Continue? [y/N] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) exit 1;;
    esac
done

curl -s https://raw.githubusercontent.com/dvillaj/NoSQL-Services/master/scripts/setup.sh | bash

if [ $? -eq 0 ]; then
   rm -f ~/notebooks/.install;
   echo "Done :-)"
else
   echo "Oops! something went wrong :-("
fi