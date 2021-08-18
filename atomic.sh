#!/usr/bin/env bash
git clone https://github.com/tonykastaneda/.dotfiles
git clone https://github.com/tonykastaneda/RayCastScripts
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock
defaults write NSGlobalDomain _HIHideMenuBar -bool true
cd ~/Documents
mkdir "Web Projects"
mkdir "Screenshots"
cd ~/.dotfiles
sh installer.sh
sh brew.sh