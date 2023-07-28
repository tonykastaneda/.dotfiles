#!/usr/bin/env bash

# Remove current install of ZSH
rm -r -f "~/.zsh";
rm -r -f "~/.zshrc";
rm -r -f "~/.zsh_history";

# Sym Linking ZSH Install
ln -s ~/.dotfiles/ZSH/.zsh ~/.zsh;
ln -s ~/.dotfiles/ZSH/.zshrc ~/.zshrc;

# FZF Install
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; 
# ~/.fzf/install;
