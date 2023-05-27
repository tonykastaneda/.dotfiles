#!/usr/bin/env bash

git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;

# Execute Privileges
chmod +x zsh.sh;
chmod +x raycast.sh;
chmod +x brew.sh;
chmod +x desktopenv.sh;
chmod +x nonbrew.sh;

# Script Installers
sh zsh.sh;
sh raycast.sh;
sh brew.sh;
sh desktop.sh;
sh hyper.sh;
sh nonbrew.sh;

# Bottle Opener
open -a "arc"
