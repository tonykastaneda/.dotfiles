#!/bin/sh

if [ -d "~/.zshrc" ] && [ ! -L "~/.zshrc" ] && echo "Directory ~/.zshrc exists." || echo "Error: Directory ~/.zshrc exists but point to $(readlink -f ~/.zshrc)."
then
  echo "rm -r ~/.zshrc"
else
  ech "ln -s ~/.dotfiles/.zshrc ~/.zshrc"



# This is an inline comment in bash
# ln -s ~/.dotfiles/.zshrc ~/.zshrc;
# In -s ~/.dotfiles/.zsh ~/.zsh;
# ln -s ~/.dotfiles/.vimrc ~/.vimrc;
# ln -s ~/.dotfiles/.vim ~/.vim
