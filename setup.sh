#!/bin/bash


if ! test -f "steamcmd.sh"
then
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
else
    echo "steamcmd.sh already exists no need to download"
fi


if ! test -f "steamcmd.sh"
then
    echo "Downloading and extracting steamcmd failed"
    exit 1
fi

if test -z "$1"
then
    echo "You have not provided a directory for installing Conan: Exiles. Assuming the default dir value of 'conan'"
    serverDir="conan"
else
    serverDir="$1"
fi

if test -d "$serverDir"
then
    echo "Directory $serverDir already exists! If you wish to re-install move or delete this dir first ie: mv $serverDir $serverDir.bck or rm -rf $serverDir"
else
    mkdir $serverDir
fi

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

modFile="$serverDir/"$serverDir"Mods.list"
mkdir $modFile

echo "The modfile to add mod IDs to is $modFile"
echo "Each line add a new mod ID and only the mod ID."
echo "You will also need to create and link the mods here: $serverDir/ConanSandbox/Mods/modlist.txt"
echo "To learn more visit: https://conanexiles.fandom.com/wiki/Dedicated_Server_Setup:_Linux_and_Wine#Adding_Mods"
echo "NOTE: the script manages the mod and updates it for you that is what the $modFile is for."

echo "This script will check the firewall on this device."
echo "NOTE: Make sure too open up port forwarding for 7777/udp 7778/udp 27015/udp 25575/tcp"

if ! command -v firewall-cmd &> /dev/null
then
    echo "firewall-cmd could not be found"
    echo "Cannot edit the firewall on this machine!"
    echo "Install finished"
    exit 0
fi

fd_state=$(firewall-cmd --state 2>&1)
if [ "$fd_state" == "not running" ]
then
    echo "Firewall not running.. no need to edit the firewall"
    echo "Install finished"
    exit 0
fi

echo "Opening up ports: 7777/udp 7778/udp 27015/udp 25575/tcp"

firewall-cmd --permanent --add-port=7777/udp
firewall-cmd --permanent --add-port=7778/udp
firewall-cmd --permanent --add-port=27015/udp
firewall-cmd --permanent --add-port=25575/tcp

systemctl restart firewalld

echo "Install finished"
exit 0
