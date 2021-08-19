#!/usr/bin/env bash
cd ~;
git clone https://github.com/tonykastaneda/.dotfiles;
cd ~/Documents;
git clone https://github.com/tonykastaneda/RayCastScripts;
mkdir "Web Projects";
mkdir "Screenshots";
cd ~/.dotfiles;
sh installer.sh;
sh brew.sh;
