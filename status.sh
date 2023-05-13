#!/bin/bash

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

if ! test -f "conan_$serverDir.lockfile"
then
    echo "Conan server in dir $serverDir has never ran before"
fi

if test -s "conan_$serverDir.lockfile"
then
    conan_pid=$(cat "conan_$serverDir.lockfile" | tr -d '\n')
    if test -z "$conan_pid"
    then
        echo "PID lock file is empty... Conan must not be running."
        exit 0
    fi
    if ps -p $conan_pid > /dev/null
    then
        echo "Conan server in dir $serverDir is running with PID: $conan_pid"
    else
        echo "Conan PID is invalid. Must not be running... Clenaing up."
        echo "" > "conan_$serverDir.lockfile"
    fi
else
    echo "Conan server in dir $serverDir is not running"
fi
