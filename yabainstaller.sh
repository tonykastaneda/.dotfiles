#!/bin/bash
rm -r -f /usr/local/bin/limelight;
rm -r -f ~/.config/yabai;
rm -r -f ~/.config/skhd;
rm -r -f ~/.config/limelight;


ln -s ~/.dotfiles/YABAI/yabai ~/.config/yabai;
ln -s ~/.dotfiles/YABAI/skhd ~/.config/skhd;
ln -s ~/.dotfiles/YABAI/limelight  ~/.config/limelight;
ln -s ~/.dotfiles/YABAI/limelight-source/bin/limelight /usr/local/bin/limelight;

