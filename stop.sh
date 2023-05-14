#!/bin/bash

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

screen -S $serverDir -p 0 -X stuff "^c"

echo "Attempting to wait for Conan Exiles to stop"
counter=0
i=1
sp="/-\|"
echo -n ' '
until [ $counter -gt 60 ]
do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 1
    ((counter=counter+1))
    if ! screen -list | grep -q $serverDir
    then
        break
    fi
done

echo ""
echo "Conan: Exiles server has stopped... checking"
echo ""

/bin/bash status.sh $serverDir
