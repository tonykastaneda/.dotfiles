#!/usr/bin/env bash

set -e

# -------------- Codex CLI -------------------

if ! command -v codex >/dev/null 2>&1; then
	curl -fsSL https://chatgpt.com/codex/install.sh | sh
fi

# -------------- Claude Code CLI -------------------

if ! command -v claude >/dev/null 2>&1; then
	curl -fsSL https://claude.ai/install.sh | bash
fi

# -------------- Cursor CLI -------------------

if ! command -v cursor-agent >/dev/null 2>&1; then
	curl https://cursor.com/install -fsS | bash
fi

# -------------- Grok CLI -------------------

if ! command -v grok >/dev/null 2>&1; then
	curl -fsSL https://x.ai/cli/install.sh | bash
fi

# -------------- Tode -------------------

if ! command -v tode >/dev/null 2>&1; then
	curl -fsSL https://tode.sh/install | bash
fi

# -------------- Terminal Browser -------------------

if ! command -v terminal-browser >/dev/null 2>&1; then
	curl -fsSL https://terminal-browser.sh/install | bash
fi
