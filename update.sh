#!/bin/bash

CONAN_BASE_DIR=$(pwd)

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir "$CONAN_BASE_DIR/$serverDir" +app_update 443030 +exit


input="$serverDir/${serverDir}Mods.list"
if test -f $input
then
  while IFS= read -r MOD_ID
  do
    ./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir "$CONAN_BASE_DIR/$serverDir" +workshop_download_item 440900 "$MOD_ID" +exit
  done < "$input"
fi
