#!/usr/bin/env bash

# dotfiles git clone
git clone https://github.com/tonykastaneda/.dotfiles ~/.dotfiles && cd ~/.dotfiles;

# Execute Privileges
chmod a+x install-brew.sh;
chmod a+x install-config.sh;
chmod a+x install-deskenv.sh;

# Script Installers
./install-brew.sh;
./install-config.sh;
./install-deskenv.sh;
