#!/usr/bin/env bash
echo "It was Lit"
defaults write com.apple.Dock autohide-delay -float 0.0001; killall Dock
