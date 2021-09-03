#!/usr/bin/env bash

git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;

# Execute Privileges
chmod +x brew.sh;
chmod +x vimstaller.sh;
chmod +x zshstaller.sh;
chmod +x raycaststaller.sh;
chmod +x desktopenv.sh;
chmod +x symlinkstaller.sh;

# Script Installers
sh brew.sh;
sh vimstaller.sh;
sh zshstaller.sh;
sh raycaststaller.sh;
sh yabainstaller.sh;
sh desktopenv.sh;
sh symlinkstaller.sh;

# Final Output
open -a "iTerm2" && killall Terminal
