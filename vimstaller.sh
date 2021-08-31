#!/usr/bin/env bash

# Remove Current Install of Vim
rm -r -f "~/.vim";
rm -r -f "~/.vimrc";
rm -r -f "~/.viminfo";
rm -r -f "~/.config/nvim"

# Sym Linking Vim Install
ln -s ~/.dotfiles/VIM/.vim ~/.vim;
ln -s ~/.dotfiles/VIM/.vimrc ~/.vimrc;
ln -s ~/.dotfiles/VIM/nvim ~/.config/nvim

# Auto Vim-Plug
vim +'PlugInstall --sync' +qa;