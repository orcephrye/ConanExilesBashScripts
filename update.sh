#!/bin/bash

CONAN_BASE_DIR=$(pwd)

if test -z "$1"
then
    serverDir="conan"
else
    serverDir="$1"
fi

./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$CONAN_BASE_DIR/$serverDir" +login anonymous +app_update 443030 +exit


input="$serverDir/${serverDir}Mods.list"
if test -f $input
then
  while IFS= read -r MOD_ID
  do
    if test -z "$MOD_ID"; then
      continue
    fi
    echo "Downloading/Update MOD ID: $MOD_ID..."
    ./steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$CONAN_BASE_DIR/$serverDir" +login anonymous +workshop_download_item 440900 "$MOD_ID" +exit
    echo "Finished trying to download $MOD_ID..."
    echo ""
  done < "$input"
fi
