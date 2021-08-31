#!/usr/bin/env bash

# Running Apps In Dock Only
defaults write com.apple.dock static-only -bool true; killall Dock;

# Desktop Picture from /img folder
osascript -e 'tell application "System Events" to tell every desktop to set picture to "~/.dotfiles/MISC/img/desktop.png"';

# Auto Hide Dock
defaults write com.apple.Dock autohide -bool TRUE; killall Dock;

# Instant Dock Auto Hide PopUp
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock;

# Auto Hide Menubar -- must close all apps ie terminal
defaults write NSGlobalDomain _HIHideMenuBar -bool true; killall Finder;
