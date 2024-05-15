#!/usr/bin/env bash

# -------------- .CONFIG -------------------

# Remove Current .config folder if any
rm -r -f "~/.config";

# Sym Linking ZSH Install
ln -s ~/dotfiles/.config ~/.config;


# -------------- .ZSH -------------------

# Remove Current .zshrc if any
rm -r -f "~/.zsh";
rm -r -f "~/.zshrc";
rm -r -f "~/.zsh_history";

# Sym Linking ZSH Install
ln -s ~/dotfiles/.config/zsh/.zsh ~/.zsh;
ln -s ~/dotfiles/.config/zsh/.zshrc ~/.zshrc;

# FZF Install
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; 
~/.fzf/install;


# -------------- .VIM -------------------

