#!/bin/bash

if [ "$EUID" -eq 0 ]; then 
  echo "Do not run as root! Run as the user that the service should start as or the user directory it is installed under"
  exit
fi


if ! test -f "steamcmd.sh"; then
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
else
    echo "steamcmd.sh already exists no need to download"
fi


if ! test -f "steamcmd.sh"; then
    echo "Downloading and extracting steamcmd failed"
    echo "The command used was: 'curl -sqL \"https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz\" | tar zxvf -'"
    echo "The URL may have changed this is the first thing to check."
    exit 1
fi

echo "Checking for dependencies "

if ! command -v wine &> /dev/null; then
    echo "Could not find the command 'wine'. This is required too run Conan Exiles. Please use your Linux Distro's package management system to install 'wine'"
    echo "The three primary dependencies are: 'wine', 'screen', 'xvfb-run'"
fi

if ! command -v screen &> /dev/null; then
    echo "Could not find the command 'screen'. This is required too run Conan Exiles. Please use your Linux Distro's package management system to install 'screen'"
    echo "The three primary dependencies are: 'wine', 'screen', 'xvfb-run'"
fi

if ! command -v xvfb-run &> /dev/null; then
    echo "Could not find the command 'xvfb-run'. This is required too run Conan Exiles. Please use your Linux Distro's package management system to install 'xvfb-run'"
    echo "The three primary dependencies are: 'wine', 'screen', 'xvfb-run'"
fi


if test -z "$1"; then
    echo "You have not provided a directory for installing Conan: Exiles. Assuming the default dir value of 'conan'"
    serverDir="conan"
else
    serverDir="$1"
fi

if test -d "$serverDir"; then
    echo "Directory $serverDir already exists! If you wish to re-install move or delete this dir first ie: mv $serverDir $serverDir.bck or rm -rf $serverDir"
else
    mkdir $serverDir
fi

CONAN_USER=$(whoami)
CONAN_INSTANCE_NAME=$serverDir
CONAN_BASE_DIR=$(pwd)


echo "==================================================="
echo "Installing $CONAN_INSTANCE_NAME in $CONAN_BASE_DIR"
echo "This will be using the $CONAN_USER user"
echo "==================================================="
read -n 1 -s -r -p "Press any key to continue"
echo ""

echo "Installing Conan: Exiles"
./update.sh $serverDir

echo "Conan needs to start for the first time in order to build directories. Once it has been started fully and stopped mods can be added"

./start.sh $serverDir

echo "Sleeping for 60 seconds"

counter=0
i=1
sp="/-\|"
echo -n ' '
until [ $counter -gt 60 ]
do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 1
    ((counter=counter+1))
done

echo ""

./stop.sh $serverDir

modFile="$serverDir/${serverDir}Mods.list"
mkdir $modFile

echo ""
echo "The modfile to add mod IDs to is $modFile"
echo "Each line add a new mod ID and only the mod ID."
echo "You will also need to create the dir/file here $serverDir/ConanSandbox/Mods/modlist.txt then add paths for the mods"
echo "To learn more visit: https://conanexiles.fandom.com/wiki/Dedicated_Server_Setup:_Linux_and_Wine#Adding_Mods"
echo "NOTE: the script manages the mod and updates it for you that is what the $modFile is for."
echo ""
echo "Important configuration files located $CONAN_BASE_DIR/$serverDir/ConanSandbox/Saved/Config/WindowsServer/ "
echo "The following 3 files are of most import:"
echo "$serverDir/ConanSandbox/Saved/Config/WindowsServer/Engine.ini"
echo "$serverDir/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini"
echo "$serverDir/ConanSandbox/Saved/Config/WindowsServer/Game.ini"
echo ""


echo ""
echo "This script will now check the firewall on this device."
echo "NOTE: Make sure too open up port forwarding on your router for 7777/udp 7778/udp 27015/udp 25575/tcp"
echo ""


if ! command -v firewall-cmd &> /dev/null; then
    echo "firewall-cmd could not be found"
    echo "Cannot edit the firewall on this machine!"
elif [ "$(firewall-cmd --state 2>&1)" == "not running" ]; then
    echo "Firewall not running.. no need to edit the firewall"
else
    echo "Opening up ports: 7777/udp 7778/udp 27015/udp 25575/tcp"

    firewall-cmd --permanent --add-port=7777/udp
    firewall-cmd --permanent --add-port=7778/udp
    firewall-cmd --permanent --add-port=27015/udp
    firewall-cmd --permanent --add-port=25575/tcp

    systemctl restart firewalld
fi

echo ""
echo "Do you want to install a systemd control script?"
echo ""
read -p "Please enter (y/n) " yn

if [[ $yn =~ ^[Yy]$ ]]; then
    echo ""
    cp template_conan_service.service conan_$CONAN_INSTANCE_NAME.service
    sed -i "s/<CONAN_USER>/$CONAN_USER/g" conan_$CONAN_INSTANCE_NAME.service
    sed -i "s/<CONAN_INSTANCE_NAME>/$CONAN_INSTANCE_NAME/g" conan_$CONAN_INSTANCE_NAME.service
    sed -i "s|<CONAN_BASE_DIR>|$CONAN_BASE_DIR|g" conan_$CONAN_INSTANCE_NAME.service
    sudo mv conan_$CONAN_INSTANCE_NAME.service /etc/systemd/system/conan_$CONAN_INSTANCE_NAME.service
    systemctl daemon-reload
    systemctl enable conan_$CONAN_INSTANCE_NAME.service
    echo ""
    echo "You can now run systemctl start conan_$CONAN_INSTANCE_NAME as well as status and stop commands to control the instance"
fi

echo "Install finished"
exit 0
