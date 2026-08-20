#!/bin/zsh

# ai — Unified Claude Code + Codex session launcher
# Uses fzf for the searchable picker.

set -u

# ------------------------------------------------------------
# Ensure fzf is installed and at least MIN_FZF_VERSION.
# Silent unless fzf is missing or outdated, in which case it
# prompts before installing/updating anything.
# ------------------------------------------------------------

MIN_FZF_VERSION="0.74.3"

version_lt() {
    [[ "$1" == "$2" ]] && return 1
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

confirm() {
    local reply
    printf "%s [y/N] " "$1"
    read -r reply
    [[ "$reply" == [Yy]* ]]
}

install_fzf() {
    if command -v brew >/dev/null 2>&1; then
        brew install fzf
    else
        git clone https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --bin
    fi
}

update_fzf() {
    if command -v brew >/dev/null 2>&1; then
        if brew list --formula fzf >/dev/null 2>&1; then
            brew upgrade fzf
        else
            brew install fzf
        fi
    fi

    local after_brew
    after_brew="$(fzf --version 2>/dev/null | awk '{print $1}')"

    # brew didn't get us to MIN_FZF_VERSION (or brew isn't installed) — fall back to git.
    if [[ -z "$after_brew" ]] || version_lt "$after_brew" "$MIN_FZF_VERSION"; then
        if [[ -d "$HOME/.fzf/.git" ]]; then
            (cd "$HOME/.fzf" && git pull && ./install --bin)
        else
            git clone https://github.com/junegunn/fzf.git "$HOME/.fzf"
            "$HOME/.fzf/install" --bin
        fi
    fi
}

ensure_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        confirm "fzf is not installed. Install it now?" || { echo "fzf is required to continue."; exit 1; }

        install_fzf

        if command -v fzf >/dev/null 2>&1; then
            echo "fzf installed ($(fzf --version | awk '{print $1}'))."
        else
            echo "fzf install failed."
            exit 1
        fi
        return
    fi

    local current
    current="$(fzf --version 2>/dev/null | awk '{print $1}')"
    [[ -n "$current" ]] || return

    if version_lt "$current" "$MIN_FZF_VERSION"; then
        confirm "fzf $current is older than the recommended $MIN_FZF_VERSION. Update now?" || return

        update_fzf

        local updated
        updated="$(fzf --version 2>/dev/null | awk '{print $1}')"
        if [[ -n "$updated" && "$updated" != "$current" ]]; then
            echo "fzf updated: $current -> $updated"
        fi
    fi
}

ensure_fzf

CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"
CURSOR_DIR="$HOME/.cursor"
GROK_DIR="$HOME/.grok"

BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'
ORANGE=$'\033[38;5;208m'
BLUE=$'\033[38;5;39m'
GREEN=$'\033[38;5;82m'
LAVENDER=$'\033[38;5;141m'

declare -a PROVIDERS
declare -a SESSION_IDS
declare -a TITLES
declare -a TIMES
declare -a WORKSPACES

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

format_time() {
    local epoch="$1"
    date -r "$epoch" "+%Y-%m-%d %H:%M" 2>/dev/null || echo ""
}

# Pull a scalar string value out of flat JSON without a jq dependency.
# Matches "key":"value" regardless of field order.
json_str() {
    local file="$1" key="$2"
    grep -o "\"${key}\": *\"[^\"]*\"" "$file" 2>/dev/null |
        head -1 |
        sed -E "s/\"${key}\": *\"//;s/\"\$//"
}

add_session() {
    PROVIDERS+=("$1")
    SESSION_IDS+=("$2")
    TITLES+=("$3")
    TIMES+=("$4")
    WORKSPACES+=("${5:-}")
}

# ------------------------------------------------------------
# Claude Code
# ------------------------------------------------------------

load_claude() {
    local projects="$CLAUDE_DIR/projects"

    [[ -d "$projects" ]] || return

    # NOTE: locals must be declared once, outside the loop body — declaring
    # them fresh on every iteration of a `while read < <(...)` loop causes
    # zsh to spew `var=value` lines to stdout.
    local file id title mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        id="$(basename "$file" .jsonl)"
        mtime="$(stat -f "%m" "$file" 2>/dev/null || echo 0)"

        # Try to grab the first user message as the title.
        # Avoid jq dependency: pull a useful-looking text fragment.
        title="$(
            grep -m1 '"type":"user"' "$file" 2>/dev/null |
            sed -E 's/.*"content":"([^"]*)".*/\1/' |
            cut -c1-70
        )"

        [[ -n "$title" ]] || title="Claude session"

        add_session \
            "Claude" \
            "$id" \
            "$title" \
            "$mtime"

    done < <(
        find "$projects" \
            -type f \
            -name '*.jsonl' \
            2>/dev/null
    )
}

# ------------------------------------------------------------
# Codex
# ------------------------------------------------------------

load_codex() {
    local sessions="$CODEX_DIR/sessions"

    [[ -d "$sessions" ]] || return

    local file filename id title mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        filename="$(basename "$file")"
        mtime="$(stat -f "%m" "$file" 2>/dev/null || echo 0)"

        # Codex rollout filenames commonly contain the session UUID.
        id="$(
            echo "$filename" |
            grep -Eo \
                '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}' |
            tail -1
        )"

        [[ -n "$id" ]] || id="${filename%.jsonl}"

        # Try to locate first actual user prompt.
        title="$(
            grep -m1 '"role":"user"' "$file" 2>/dev/null |
            sed -E 's/.*"content":"([^"]*)".*/\1/' |
            cut -c1-70
        )"

        [[ -n "$title" ]] || title="Codex session"

        add_session \
            "Codex" \
            "$id" \
            "$title" \
            "$mtime"

    done < <(
        find "$sessions" \
            -type f \
            -name '*.jsonl' \
            2>/dev/null
    )
}

# ------------------------------------------------------------
# Cursor
# ------------------------------------------------------------

load_cursor() {
    local chats="$CURSOR_DIR/chats"

    [[ -d "$chats" ]] || return

    local file id title cwd mtime_ms mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        # Skip chats that were opened but never actually used.
        grep -q '"hasConversation": *true' "$file" 2>/dev/null || continue

        id="$(basename "$(dirname "$file")")"

        title="$(json_str "$file" title)"
        [[ -n "$title" ]] || title="Cursor session"

        cwd="$(json_str "$file" cwd)"

        mtime_ms="$(grep -o '"updatedAtMs": *[0-9]*' "$file" 2>/dev/null | head -1 | grep -o '[0-9]*$')"
        if [[ -n "$mtime_ms" ]]; then
            mtime=$(( mtime_ms / 1000 ))
        else
            mtime="$(stat -f "%m" "$file" 2>/dev/null || echo 0)"
        fi

        add_session \
            "Cursor" \
            "$id" \
            "$title" \
            "$mtime" \
            "$cwd"

    done < <(
        find "$chats" \
            -type f \
            -name 'meta.json' \
            2>/dev/null
    )
}

# ------------------------------------------------------------
# Grok
# ------------------------------------------------------------

load_grok() {
    local sessions="$GROK_DIR/sessions"

    [[ -d "$sessions" ]] || return

    local file id title cwd chat mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        chat="$(dirname "$file")/chat_history.jsonl"

        # Skip sessions that were opened but never actually used.
        [[ -f "$chat" ]] || continue

        id="$(basename "$(dirname "$file")")"

        cwd="$(json_str "$file" cwd)"

        # session_summary is usually empty, so fall back to the first
        # genuinely-typed user message — skip injected <system-reminder>
        # turns, which aren't something the user actually wrote.
        title="$(json_str "$file" session_summary)"

        if [[ -z "$title" ]]; then
            title="$(
                grep '"type":"user"' "$chat" 2>/dev/null |
                sed -E 's/.*"text":"([^"]*)".*/\1/' |
                grep -v '^<system-reminder>' |
                head -1 |
                cut -c1-70
            )"
        fi

        # No genuine user turn anywhere in this session — it's not a real
        # conversation, so skip it entirely rather than showing junk.
        [[ -n "$title" ]] || continue

        mtime="$(stat -f "%m" "$chat" 2>/dev/null || stat -f "%m" "$file" 2>/dev/null || echo 0)"

        add_session \
            "Grok" \
            "$id" \
            "$title" \
            "$mtime" \
            "$cwd"

    done < <(
        find "$sessions" \
            -type f \
            -name 'summary.json' \
            2>/dev/null
    )
}

# ------------------------------------------------------------
# Load
# ------------------------------------------------------------

load_claude
load_codex
load_cursor
load_grok

COUNT=${#SESSION_IDS[@]}

if (( COUNT == 0 )); then
    echo "No Claude Code, Codex, Cursor, or Grok sessions found."
    exit 1
fi

# ------------------------------------------------------------
# Sort newest first
#
# zsh arrays are 1-indexed by default, so indices must run 1..COUNT
# (not 0..COUNT-1) to line up with PROVIDERS/SESSION_IDS/TITLES/TIMES.
# ------------------------------------------------------------

declare -a ORDER

while IFS= read -r index; do
    ORDER+=("$index")
done < <(
    for ((i=1; i<=COUNT; i++)); do
        printf '%s %s\n' "${TIMES[$i]}" "$i"
    done |
    sort -rn |
    awk '{print $2}'
)

# ------------------------------------------------------------
# --list / -l: print the 10 most recent conversations and exit
# ------------------------------------------------------------

if [[ "${1:-}" == "-l" || "${1:-}" == "--list" ]]; then
    shown=0
    printf "%s%-8s  %-16s  %-50s%s\n" "$BOLD" "Agent" "Time" "Conversation" "$RESET"
    for index in "${ORDER[@]}"; do
        (( shown >= 10 )) && break
        printf "%-8s  %-16s  %-50s\n" \
            "${PROVIDERS[$index]}" \
            "$(format_time "${TIMES[$index]}")" \
            "${TITLES[$index][1,50]}"
        ((shown++))
    done
    exit 0
fi

# ------------------------------------------------------------
# fzf searchable selector
# ------------------------------------------------------------

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required. Install it with: brew install fzf"
    exit 1
fi

declare -a MENU_LINES
declare provider_color

for index in "${ORDER[@]}"; do
    case "${PROVIDERS[$index]}" in
        Claude) provider_color="$ORANGE" ;;
        Codex)  provider_color="$BLUE" ;;
        Grok)   provider_color="$GREEN" ;;
        Cursor) provider_color="$LAVENDER" ;;
        *)      provider_color="$RESET" ;;
    esac

    MENU_LINES+=("${provider_color}${PROVIDERS[$index]}${RESET}"$'\t'"$(format_time "${TIMES[$index]}")"$'\t'"${TITLES[$index]}"$'\t'"${index}")
done

clear

selection="$(
    printf '%s\n' "${MENU_LINES[@]}" |
    fzf \
        --ansi \
        --delimiter=$'\t' \
        --with-nth=1,2,3 \
        --prompt="Resume> " \
        --height=35 \
        --layout=reverse \
        --header="Agent    Time              Conversation" \
        --footer=$'↑↓ navigate  |  ENTER resume  |  ESC quit'
)"

[[ -n "$selection" ]] || exit 0

selected="${selection##*$'\t'}"

provider="${PROVIDERS[$selected]}"
session="${SESSION_IDS[$selected]}"
title="${TITLES[$selected]}"
workspace="${WORKSPACES[$selected]}"

clear

printf "%sResuming%s\n" "$BOLD" "$RESET"
printf "%s%s%s\n\n" "$DIM" "$title" "$RESET"

# ------------------------------------------------------------
# Launch correct agent
# ------------------------------------------------------------

case "$provider" in

    Claude)

        if ! command -v claude >/dev/null 2>&1; then
            echo "claude command not found."
            exit 1
        fi

        exec claude --resume "$session"
        ;;

    Codex)

        if ! command -v codex >/dev/null 2>&1; then
            echo "codex command not found."
            exit 1
        fi

        exec codex resume "$session"
        ;;

    Cursor)

        if ! command -v cursor-agent >/dev/null 2>&1; then
            echo "cursor-agent command not found."
            exit 1
        fi

        if [[ -n "$workspace" ]]; then
            exec cursor-agent --resume "$session" --workspace "$workspace"
        else
            exec cursor-agent --resume "$session"
        fi
        ;;

    Grok)

        if ! command -v grok >/dev/null 2>&1; then
            echo "grok command not found."
            exit 1
        fi

        if [[ -n "$workspace" ]]; then
            exec grok --resume "$session" --cwd "$workspace"
        else
            exec grok --resume "$session"
        fi
        ;;

esac
