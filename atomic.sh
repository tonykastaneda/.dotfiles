#!/usr/bin/env bash
git clone https://github.com/tonykastaneda/.dotfiles;
git clone https://github.com/tonykastaneda/RayCastScripts;
cd ~/Documents;
mkdir "Web Projects";
mkdir "Screenshots";
cd ~/.dotfiles;
sh installer.sh;
sh brew.sh;
