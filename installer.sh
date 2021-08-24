#!/usr/bin/env bash
rm -r -f "~/.zsh";
rm -r -f "~/.zshrc";
rm -r -f "~/.zsh_history";
rm -r -f "~/.vim";
rm -r -f "~/.vimrc";
rm -r -f "~/.viminfo";
rm -r -f "~/.config/nvim"
ln -s ~/.dotfiles/.vim ~/.vim;
ln -s ~/.dotfiles/.vimrc ~/.vimrc;
ln -s ~/.dotfiles/.zsh ~/.zsh;
ln -s ~/.dotfiles/.zshrc ~/.zshrc;
ln -s ~/.dotfiles/nvim ~/.config/nvim
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; 
~/.fzf/install
