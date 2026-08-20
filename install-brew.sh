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

# Put brew on PATH for the rest of this script (installer only wires up ~/.zprofile for future shells)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi


# DEPENDENCIES
brew install python
brew install node
brew install yarn
brew install git
brew install fastfetch
brew install lsd
brew install neovim
brew install nnn
brew install htop
brew install fzf




# GUI-APPLICATIONS
brew install google-chrome
brew install zed
brew install raycast
brew install daisydisk
brew install dockey
brew install vlc
brew install appcleaner
brew install slack
brew install macs-fan-control
brew install zen
brew install imageoptim
brew install superkey
brew install rightfont
brew install cleanshot
brew install rectangle-pro
brew install rocket
brew install google-drive
brew install adobe-creative-cloud
