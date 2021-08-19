#!/usr/bin/env bash
git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;
sh installer.sh;
sh brew.sh;
cd ~/Documents;
git clone https://github.com/tonykastaneda/RayCastScripts;
mkdir "Web Projects";
mkdir "Screenshots";
