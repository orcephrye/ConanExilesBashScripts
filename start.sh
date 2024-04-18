#!/bin/bash

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

/bin/bash update.sh $serverDir
screen -dm -S $serverDir bash -c "conan.sh $serverDir"

sleep 2

/bin/bash status.sh $serverDir
