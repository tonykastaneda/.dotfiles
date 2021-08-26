#!/usr/bin/env bash
readPassword
echo $PASSWORD | awk '{print $1}'

readPassword() {
   echo -n "Password: "
   read -s PASSWORD
   echo ""
   if [[ -z "$PASSWORD" ]]; then
      printf '%s\n' "A password is required..."
      readPassword
   fi
}

# START
git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;
# Vim & Terminal Installer
sh installer.sh;
# Brew File Installer
sh brew.sh;
# RayCast Directories and Scripts
cd ~/Documents;
git clone https://github.com/tonykastaneda/RayCastScripts;
mkdir "Web Projects";
mkdir "Screenshots";
# Vim Auto - Post Installer
vim +'PlugInstall --sync' +qa;
# Running Apps In Dock Only
defaults write com.apple.dock static-only -bool true; killall Dock;
# Desktop Picture from /img folder
osascript -e 'tell application "System Events" to tell every desktop to set picture to "~/.dotfiles/.misc/img/desktop.png"';
# Auto Hide Dock
defaults write com.apple.Dock autohide -bool TRUE; killall Dock;
# Instant Dock Auto Hide PopUp
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock;
# Auto Hide Menubar -- must close all apps ie terminal
defaults write NSGlobalDomain _HIHideMenuBar -bool true; killall Finder;
open -a "iTerm"; 
killall Terminal



