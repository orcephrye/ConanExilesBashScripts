#!/bin/bash

CONAN_BASE_DIR=$(pwd)
CONAN_USER=$(whoami)

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

echo $$ > conan_$serverDir.lockfile

export WINEARCH=win64; export WINEPREFIX=/home/$CONAN_USER/.wine64; xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine "$CONAN_BASE_DIR/$serverDir/ConanSandboxServer.exe" -log 

kill -9 $(pgrep -P $$)

echo "" > conan_$serverDir.lockfile
