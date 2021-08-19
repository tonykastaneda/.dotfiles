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
git clone https://github.com/tonykastaneda/.dotfiles && cd ~/.dotfiles;
sh installer.sh;
sh brew.sh;
cd ~/Documents;
git clone https://github.com/tonykastaneda/RayCastScripts;
mkdir "Web Projects";
mkdir "Screenshots";
vim +'PlugInstall --sync' +qa;
# Running Apps In Dock Only
defaults write com.apple.dock static-only -bool true; killall Dock;
# Desktop Picture Setter
osascript -e 'tell application "System Events" to tell every desktop to set picture to "~/.dotfiles/img/desktop.png"';
# Auto Hide Dock
defaults write com.apple.Dock autohide -bool TRUE; killall Dock;
# Instant Dock Auto Hide PopUp
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock;
# Auto Hide Menubar -- must close all apps ie terminal
defaults write NSGlobalDomain _HIHideMenuBar -bool true; killall Finder;
open -a "iTerm"; 
killall Terminal



