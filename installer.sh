#!/bin/bash
rm -r -f "~/.zsh";
rm -r -f "~/.zshrc";
rm -r -f "~/.zsh_history";
rm -r -f "~/.vim";
rm -r -f "~/.vimrc";
rm -r -f "~/.viminfo";
ln -s ~/.dotfiles/.vim ~/.vim;
ln -s ~/.dotfiles/.vim/.vimrc ~/.vimrc;
ln -s ~/.dotfiles/.zsh ~/.zsh;
ln -s ~/.dotfiles/.zsh/.zshrc ~/.zshrc;
