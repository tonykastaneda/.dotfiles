#!/usr/bin/env bash

set -e

DOTFILES="$HOME/.dotfiles"

# -------------- .ZSH -------------------

# Sym Linking ZSH Install (ln -sf replaces just these symlinks, never touches ~/.config)
ln -sf "$DOTFILES/.config/zsh/.zsh" "$HOME/.zsh"
ln -sf "$DOTFILES/.config/zsh/.zshrc" "$HOME/.zshrc"


# -------------- NVIM (LazyVim) -------------------

# Neovim Install
if ! command -v nvim >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then
		brew install neovim
	else
		echo "Homebrew not found — install Neovim manually: https://github.com/neovim/neovim/blob/master/INSTALL.md"
	fi
fi

# Sym Linking LazyVim config (XDG path — nvim expects it at ~/.config/nvim)
ln -sf "$DOTFILES/.config/nvim" "$HOME/.config/nvim"

# Install/sync plugins headlessly
nvim --headless "+Lazy! sync" +qa


# -------------- HERDR -------------------

# Sym Linking herdr config.toml only — ~/.config/herdr also holds logs,
# sockets, and session.json that shouldn't be versioned or shared.
mkdir -p "$HOME/.config/herdr"
ln -sf "$DOTFILES/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml"
