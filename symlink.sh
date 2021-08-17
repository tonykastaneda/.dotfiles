#!/bin/sh

if [ ! -L ".zsh" ]
then
	echo "YES"
else
	echo "NO"
fi


# This is an inline comment in bash
# ln -s ~/.dotfiles/.zshrc ~/.zshrc;
# In -s ~/.dotfiles/.zsh ~/.zsh;
# ln -s ~/.dotfiles/.vimrc ~/.vimrc;
# ln -s ~/.dotfiles/.vim ~/.vim
