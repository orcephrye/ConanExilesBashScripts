#!/bin/bash

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

screen -S $serverDir -X quit

sleep 3

if ! screen -list | grep -q $serverDir
then
    echo "" > "conan_$serverDir.lockfile"
fi

/bin/bash status.sh $serverDir
