#!/usr/bin/env bash

set -e

# Show only running applications in the Dock
defaults write com.apple.dock static-only -bool true

# Automatically hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# (Optional) Speed up the hide/show animation
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Apply all Dock changes
killall Dock >/dev/null 2>&1 || true

# Wallpaper
WALLPAPER="${HOME}/.dotfiles/.config/deskenv/desktop.png"

if [[ -f "$WALLPAPER" ]]; then
	osascript <<EOF
tell application "System Events"
	repeat with d in desktops
		set picture of d to POSIX file "$WALLPAPER"
	end repeat
end tell
EOF
else
	echo "Wallpaper not found:"
	echo "  $WALLPAPER"
fi


# Directories
mkdir -p "${HOME}/Documents/Screenshots"
mkdir -p "${HOME}/Documents/desktopENV"
