#!/usr/bin/env bash

# Running Apps In Dock Only
defaults write com.apple.dock static-only -bool true; killall Dock;

# Desktop Picture from /img folder
osascript -e 'tell application "System Events" to tell every desktop to set picture to "~/dotfiles/.config/deskenv/desktop.png"';

# Auto Hide Dock
defaults write com.apple.Dock autohide -bool TRUE; killall Dock;

# Instant Dock Auto Hide PopUp
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock;

# Screenshot Directory
mkdir ~/Documents/Screenshots/

# Desktop Temp
mkdir ~/Documents/DTMP/

# JetBrains Nerd Font Install
cp ~/dotfiles/.config/deskenv/jetbrains/* ~/Library/Fonts/

