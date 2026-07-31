#!/usr/bin/env bash

set -e

DOTFILES="$HOME/.dotfiles"

# -------------- .ZSH -------------------

# Sym Linking ZSH Install (ln -sf replaces just these symlinks, never touches ~/.config)
ln -sf "$DOTFILES/.config/zsh/.zsh" "$HOME/.zsh"
ln -sf "$DOTFILES/.config/zsh/.zshrc" "$HOME/.zshrc"

# FZF Install
if [ ! -d "$HOME/.fzf" ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
	"$HOME/.fzf/install" --all
fi


# -------------- .VIM -------------------

# Sym Linking Vim Install
ln -sf "$DOTFILES/.config/vim/.vimrc" "$HOME/.vimrc"

# vim-plug Install
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
	curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Plugins
vim +PlugInstall +qall
