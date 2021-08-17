#!/usr/bin/env bash
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock
defaults write NSGlobalDomain _HIHideMenuBar -bool true
git clone https://github.com/tonykastaneda/.dotfiles
cd ~/Documents
mkdir "Web Projects"
mkdir "Screenshots"
git clone https://github.com/tonykastaneda/RayCastScripts
cd ~/.dotfiles
sh installer.sh
sh brew.sh