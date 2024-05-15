#!/usr/bin/env bash

# Check if Command Line Tools are installed and install if they aren't
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Installing Command Line Tools. Please wait until the installation is complete."
    # Wait until the Command Line Tools are installed
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi

# Now install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# DEPENDENCIES
brew install cask
brew install python
brew install node
brew install yarn
brew install git
brew install fastfetch
brew install lsd
brew install yabai
brew install skhd


# GUI-APPLICATIONS
brew install google-chrome
brew install visual-studio-code
brew install raycast
brew install daisydisk
brew install dockey
brew install iina
brew install amethyst
brew install appcleaner
brew install slack
brew install numi
brew install macs-fan-control
brew install firefox
brew install imageoptim
brew install contexts
brew install superkey
brew install crossover
brew install rightfont
brew install mirrordisplays
brew install cleanshot
brew install rectangle-pro
brew install rocket
brew install google-drive
brew install adobe-creative-cloud
brew install arc