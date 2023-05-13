# ConanExilesBashScripts
Bash scripts for controlling a Conan Exiles server

The insperation for these scripts comes from reading:

https://developer.valvesoftware.com/wiki/SteamCMD#Manually

and...

https://conanexiles.fandom.com/wiki/Dedicated_Server_Setup:_Linux_and_Wine


## Dependencies

wine

screen

xvfb-run


## Usage

All these scripts take a single optional argument which is the directory that the Conan Exiles game server will be installed too. You can install and run multiple instances of Conan: Exiles (as long as you change ports) using these scripts.

IE:
```bash 
./setup.sh conanServer
```

If no argument is passed the scripts will assume the install directory is 'conan'.

./status.sh can be used at any time to determine if an instance is running and its pid. 

Alternatively you can run 'screen -ls'

## Screen

Each instance of the game runs in a screen. You can use this to check on the logs of a particular game or control it from the console.

The name of the screen is the directory name that the game is installed in.

## Mods

The 'update.sh' script reads from a file in the root dir that the game is installed in. If the game is installed in 'conan' directory then it would be in '<path_to_dir>/conan/conanMods.list'. For every Mod entry in there the script will download/install/update the mod each time the server runs.

Mods still need to the added to the 'modlist.txt' file as noted in the instructions.

## Configuration

For configuring the server please review: 
https://conanexiles.fandom.com/wiki/Dedicated_Server_Setup:_Linux_and_Wine#Configuring_the_Server

## TODOs

Need to add backup support. 

Change the way mod support works to make it more simple.

