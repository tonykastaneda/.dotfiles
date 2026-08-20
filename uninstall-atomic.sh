#!/usr/bin/env bash

# Mirror image of atomic.sh — undoes everything install-brew.sh,
# install-config.sh, and install-utility.sh install/configure.
#
# Deliberately left alone:
#   - Xcode Command Line Tools (so a future install-brew.sh run won't
#     need to redo that step)
#   - ~/.dotfiles itself (this script lives inside it; not safe to have
#     it delete its own containing directory mid-run)

set -e

echo "=== Uninstalling atomic.sh setup ==="

# -------------- Utility CLIs (install-utility.sh, reverse order) -------------------

# Terminal Browser — no built-in uninstall command, so remove exactly what
# its own receipt file (~/.local/state/terminal-browser/skills.links) lists,
# plus its binary and data dirs. Only ~/.cursor/skills/terminal-browser is
# touched inside ~/.cursor — the rest of that directory belongs to the
# separately-installed Cursor GUI app and is out of scope.
if command -v terminal-browser >/dev/null 2>&1 || [ -d "$HOME/.local/share/terminal-browser" ]; then
	echo "Removing terminal-browser..."
	rm -f "$HOME/.local/bin/terminal-browser"
	rm -rf "$HOME/.local/share/terminal-browser"
	rm -rf "$HOME/.local/state/terminal-browser"
	rm -f "$HOME/.agents/skills/terminal-browser"
	rm -f "$HOME/.claude/skills/terminal-browser"
	rm -f "$HOME/.codex/skills/terminal-browser"
	rm -f "$HOME/.cursor/skills/terminal-browser"
fi

# Tode — has its own official uninstaller, trust it
if command -v tode >/dev/null 2>&1; then
	echo "Removing tode..."
	tode --uninstall --yes
fi

# Grok CLI — everything lives under ~/.grok (confirmed via its own install
# script: binary, auth, downloads, completions all self-contained there)
if command -v grok >/dev/null 2>&1 || [ -d "$HOME/.grok" ]; then
	echo "Removing grok..."
	rm -rf "$HOME/.grok"
fi

# Cursor CLI — ~/.cursor belongs to the separately-installed Cursor GUI app
# (confirmed via ~/.cursor/argv.json, a VS Code-fork config file) and is
# deliberately NOT touched here. Only remove the bare `agent` shim if it
# still points at cursor-agent's own install path.
if command -v cursor-agent >/dev/null 2>&1 || [ -d "$HOME/.local/share/cursor-agent" ]; then
	echo "Removing cursor-agent..."
	rm -f "$HOME/.local/bin/cursor-agent"
	rm -rf "$HOME/.local/share/cursor-agent"
	if [ -L "$HOME/.local/bin/agent" ] && readlink "$HOME/.local/bin/agent" | grep -q "cursor-agent"; then
		rm -f "$HOME/.local/bin/agent"
	fi
fi

# Claude Code CLI — official native-install uninstall procedure
# (https://code.claude.com/docs/en/setup#native-installation)
if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.local/share/claude" ]; then
	echo "Removing claude..."
	rm -f "$HOME/.local/bin/claude"
	rm -rf "$HOME/.local/share/claude"
	rm -rf "$HOME/.claude"
	rm -f "$HOME/.claude.json"
fi

# Codex CLI — handles both install methods: brew cask is what's actually on
# this machine right now, the shell installer is what install-utility.sh uses
if command -v codex >/dev/null 2>&1 || [ -d "$HOME/.codex" ]; then
	echo "Removing codex..."
	if command -v brew >/dev/null 2>&1 && brew list --cask codex >/dev/null 2>&1; then
		brew uninstall --cask codex
	else
		rm -f "$HOME/.local/bin/codex" "$HOME/.local/bin/codex-code-mode-host"
	fi
	rm -rf "$HOME/.codex"
fi


# -------------- NVIM / LazyVim (install-config.sh) -------------------

echo "Removing Neovim config and LazyVim data..."
rm -f "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"
rm -rf "$HOME/.local/state/nvim"
rm -rf "$HOME/.cache/nvim"


# -------------- ZSH symlinks (install-config.sh) -------------------

echo "Removing zsh symlinks..."
rm -f "$HOME/.zsh"
rm -f "$HOME/.zshrc"


# -------------- Homebrew (install-brew.sh) -------------------
# Full uninstall — removes every formula/cask on the machine (not just the
# ones atomic.sh installed) and Homebrew itself, via Homebrew's own official
# uninstaller. Xcode Command Line Tools are left installed on purpose.

if command -v brew >/dev/null 2>&1; then
	echo "Uninstalling Homebrew (all formulae and casks)..."
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
fi

echo ""
echo "Done."
echo "Xcode Command Line Tools were left installed on purpose."
echo "~/.dotfiles (this repo) was left in place — remove it yourself with 'rm -rf ~/.dotfiles' if you want it gone too."
