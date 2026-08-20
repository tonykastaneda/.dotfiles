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

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

format_time() {
    local epoch="$1"
    date -r "$epoch" "+%Y-%m-%d %I:%M %p" 2>/dev/null || echo ""
}

# Pull a scalar string value out of flat JSON without a jq dependency.
# Matches "key":"value" regardless of field order.
json_str() {
    local file="$1" key="$2"
    grep -o "\"${key}\": *\"[^\"]*\"" "$file" 2>/dev/null |
        head -1 |
        sed -E "s/\"${key}\": *\"//;s/\"\$//"
}

# Turn a raw extracted fragment into a display-safe title: collapse
# literal \n/\t escape artifacts and repeated whitespace, and reject
# strings that still look like raw JSON or injected/synthetic preamble
# rather than something a human actually typed. Echoes "" if rejected.
clean_title() {
    local raw="$1" cleaned

    [[ -n "$raw" ]] || { echo ""; return; }

    cleaned="${raw//\\n/ }"
    cleaned="${cleaned//\\t/ }"
    cleaned="$(echo "$cleaned" | tr -s '[:space:]' ' ')"
    cleaned="${cleaned## }"
    cleaned="${cleaned%% }"

    case "$cleaned" in
        "{"*|"<"[A-Za-z]*)
            echo ""
            return
            ;;
    esac

    echo "$cleaned" | cut -c1-70
}

# Scan a JSONL transcript for the first genuinely-typed user message,
# skipping lines whose extraction fails (raw JSON leaking through) or
# whose content is synthetic/injected preamble — system reminders, tool
# tags, image-attachment references, etc.
#
# Session files can contain individual lines tens of megabytes long
# (e.g. a pasted image as inline base64) — reading such a line into an
# unbounded field, as plain awk or a naive `grep -m1 | sed` pipeline
# would, costs the better part of a second EACH, dominating startup
# time. `grep -o 'PATTERN.\{0,250\}'` extracts only a bounded window
# around each match without ever materializing the full line, so the
# huge-line cost disappears; awk then does the cheap cleanup/rejection
# work on that small piped output. 250 (not e.g. 300) because macOS's
# /usr/bin/grep hard-caps interval repetition at 255 and silently
# produces zero matches past that — no error on stdout, easy to miss.
# Avoids jq: matches either a plain string ("content":"...") or a
# nested content-array ("content":[{"text":"..."}]) shape via
# greedy-backtracking regex.
# Args: file, grep-style pattern identifying a user-turn line
extract_user_title() {
    local file="$1" role_pattern="$2"

    grep -m 20 -o "${role_pattern}.\{0,250\}" "$file" 2>/dev/null | awk '
        {
            line = $0
            if (match(line, /"(content|text)":"[^"]*"/)) {
                frag = substr(line, RSTART, RLENGTH)
                sub(/^"[a-z]+":"/, "", frag)
                sub(/"$/, "", frag)
            } else {
                next
            }
            gsub(/\\n/, " ", frag)
            gsub(/\\t/, " ", frag)
            gsub(/  +/, " ", frag)
            gsub(/^ +/, "", frag)
            gsub(/ +$/, "", frag)
            if (frag ~ /^\{/ || frag ~ /^<[a-zA-Z_-]+[ >]/) next
            if (length(frag) > 0) {
                print substr(frag, 1, 70)
                exit
            }
        }
    '
}

# ------------------------------------------------------------
# Phase 1: fast metadata-only scan per provider — no title
# extraction (that's the expensive part, deferred to Phase 2's
# emit_rows). Each scan_* prints one tab-delimited row per
# candidate session:
#   mtime  provider  titlefile  id  fallbackfile  workspace
# titlefile is what Phase 2 runs title-extraction against.
# fallbackfile is Grok-only (chat_history.jsonl, used when
# session_summary is empty) — "-" for the other three, since
# zsh's `read` collapses a genuinely-empty field that has more
# fields after it (shifting everything past it by one); a
# placeholder in a middle field sidesteps that entirely. Only
# workspace is left truly empty when unused, since it's always
# the last field and nothing follows it to shift.
# ------------------------------------------------------------

scan_claude() {
    local projects="$CLAUDE_DIR/projects"

    [[ -d "$projects" ]] || return

    # NOTE: locals must be declared once, outside the loop body — declaring
    # them fresh on every iteration of a `while read < <(...)` loop causes
    # zsh to spew `var=value` lines to stdout.
    local file id mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        id="$(basename "$file" .jsonl)"
        mtime="$(stat -f "%m" "$file" 2>/dev/null || echo 0)"

        printf '%s\tClaude\t%s\t%s\t-\t\n' "$mtime" "$file" "$id"

    done < <(
        find "$projects" \
            -type f \
            -name '*.jsonl' \
            2>/dev/null
    )
}

scan_codex() {
    local sessions="$CODEX_DIR/sessions"

    [[ -d "$sessions" ]] || return

    local file filename id mtime

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

        printf '%s\tCodex\t%s\t%s\t-\t\n' "$mtime" "$file" "$id"

    done < <(
        find "$sessions" \
            -type f \
            -name '*.jsonl' \
            2>/dev/null
    )
}

scan_cursor() {
    local chats="$CURSOR_DIR/chats"

    [[ -d "$chats" ]] || return

    local file id cwd mtime_ms mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        # Skip chats that were opened but never actually used.
        grep -q '"hasConversation": *true' "$file" 2>/dev/null || continue

        id="$(basename "$(dirname "$file")")"
        cwd="$(json_str "$file" cwd)"

        mtime_ms="$(grep -o '"updatedAtMs": *[0-9]*' "$file" 2>/dev/null | head -1 | grep -o '[0-9]*$')"
        if [[ -n "$mtime_ms" ]]; then
            mtime=$(( mtime_ms / 1000 ))
        else
            mtime="$(stat -f "%m" "$file" 2>/dev/null || echo 0)"
        fi

        printf '%s\tCursor\t%s\t%s\t-\t%s\n' "$mtime" "$file" "$id" "$cwd"

    done < <(
        find "$chats" \
            -type f \
            -name 'meta.json' \
            2>/dev/null
    )
}

scan_grok() {
    local sessions="$GROK_DIR/sessions"

    [[ -d "$sessions" ]] || return

    local file id cwd chat mtime

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        chat="$(dirname "$file")/chat_history.jsonl"

        # Skip sessions that were opened but never actually used.
        [[ -f "$chat" ]] || continue

        id="$(basename "$(dirname "$file")")"
        cwd="$(json_str "$file" cwd)"

        mtime="$(stat -f "%m" "$chat" 2>/dev/null || stat -f "%m" "$file" 2>/dev/null || echo 0)"

        printf '%s\tGrok\t%s\t%s\t%s\t%s\n' "$mtime" "$file" "$id" "$chat" "$cwd"

    done < <(
        find "$sessions" \
            -type f \
            -name 'summary.json' \
            2>/dev/null
    )
}

# ------------------------------------------------------------
# Phase 2: reads sorted Phase-1 rows from stdin and streams a
# resolved "provider mtime title id workspace project" record
# the instant each is ready — this is the only place the
# per-provider title-extraction dispatch happens.
#
# "project" is "StartFolder → LastFolderWritten" — the folder
# name (not full path) the session started in, and the folder
# name of whatever file it last wrote to. When a session never
# left its starting folder, both sides show the same name.
#
# Per-provider reliability of "last written" varies with what
# each tool actually records:
#   Claude — reliable: every Write/Edit tool call logs an exact
#     "file_path", so the true last write is known.
#   Cursor — reliable: cursor-agent also writes a plain JSONL
#     transcript (separate from its SQLite chat store) with the
#     same Write/StrReplace tool-call shape as Claude's; its
#     path is derived directly from the already-known cwd + id
#     rather than searched for.
#   Grok — best-effort/unverified: assumed to follow the same
#     "file_path" convention as Claude, but every Grok session on
#     this machine is a ghost session (see load filtering above),
#     so there is no real data to confirm this against.
#   Codex — not attempted: Codex has no dedicated write tool, it
#     runs arbitrary shell commands instead, and every regex tried
#     for spotting a file redirect in that shell text (`> foo`,
#     path-shaped targets, etc.) produced false positives against
#     real sessions (matched unrelated `>` in prose/XML-ish tags).
#     Rather than show a misleading folder, Codex just shows its
#     start folder on both sides of the arrow.
# ------------------------------------------------------------

emit_rows() {
    # NOTE: locals declared once, outside the loop body — same
    # while-read gotcha as scan_claude et al. above.
    local mtime provider titlefile id fallbackfile workspace title
    local start_path last_path start_name last_name project transcript

    while IFS=$'\t' read -r mtime provider titlefile id fallbackfile workspace; do
        last_path=""

        case "$provider" in
            Claude)
                title="$(extract_user_title "$titlefile" '"type":"user"')"
                [[ -n "$title" ]] || title="Claude session"

                start_path="$(grep -m1 -o '"cwd":"[^"]\{0,250\}"' "$titlefile" 2>/dev/null | sed -E 's/"cwd":"//;s/"$//')"
                last_path="$(grep -o '"file_path":"[^"]\{0,250\}"' "$titlefile" 2>/dev/null | tail -1 | sed -E 's/"file_path":"//;s/"$//')"
                ;;
            Codex)
                title="$(extract_user_title "$titlefile" '"role":"user"')"
                [[ -n "$title" ]] || title="Codex session"

                start_path="$(grep -m1 -o '"cwd":"[^"]\{0,250\}"' "$titlefile" 2>/dev/null | sed -E 's/"cwd":"//;s/"$//')"
                ;;
            Cursor)
                title="$(json_str "$titlefile" title)"
                [[ -n "$title" ]] || title="Cursor session"

                start_path="$workspace"
                if [[ -n "$workspace" ]]; then
                    transcript="$HOME/.cursor/projects/$(echo "$workspace" | sed 's#^/##; s#/#-#g')/agent-transcripts/${id}/${id}.jsonl"
                    if [[ -f "$transcript" ]]; then
                        last_path="$(grep -o '"name":"\(Write\|StrReplace\)","input":{"path":"[^"]\{0,250\}"' "$transcript" 2>/dev/null | tail -1 | sed -E 's/.*"path":"//;s/"$//')"
                    fi
                fi
                ;;
            Grok)
                # session_summary is usually empty, so fall back to the
                # first genuinely-typed user message.
                title="$(json_str "$titlefile" session_summary)"
                [[ -n "$title" ]] && title="$(clean_title "$title")"

                if [[ -z "$title" ]]; then
                    title="$(extract_user_title "$fallbackfile" '"type":"user"')"
                fi

                # No genuine user turn anywhere in this session — it's
                # not a real conversation, so skip it entirely rather
                # than showing junk.
                [[ -n "$title" ]] || continue

                start_path="$workspace"
                last_path="$(grep -o '"file_path":"[^"]\{0,250\}"' "$fallbackfile" 2>/dev/null | tail -1 | sed -E 's/"file_path":"//;s/"$//')"
                ;;
        esac

        start_name="${start_path:t}"
        [[ -n "$start_name" ]] || start_name="?"

        if [[ -n "$last_path" ]]; then
            last_name="${last_path:h:t}"
            [[ -n "$last_name" ]] || last_name="$start_name"
        else
            last_name="$start_name"
        fi

        project="${start_name} → ${last_name}"

        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$provider" "$mtime" "$title" "$id" "$project" "$workspace"
    done
}

# ------------------------------------------------------------
# Phase 1: run the fast scan across all four providers up front.
# No title extraction happens here, so this is expected to
# complete in well under a second even across hundreds of
# sessions — everything after this point streams.
# ------------------------------------------------------------

meta_raw="$( { scan_claude; scan_codex; scan_cursor; scan_grok; } )"

if [[ -z "$meta_raw" ]]; then
    echo "No Claude Code, Codex, Cursor, or Grok sessions found."
    exit 1
fi

# ------------------------------------------------------------
# --list / -l: print the 10 most recent conversations and exit.
# Reuses the same scan -> sort -> emit_rows pipeline as the fzf
# picker below, so the per-provider title-dispatch logic exists
# in exactly one place. `head -10` closing early also naturally
# caps title-extraction work to roughly the top 10 sessions.
# ------------------------------------------------------------

if [[ "${1:-}" == "-l" || "${1:-}" == "--list" ]]; then
    printf "%s%-8s  %-19s  %-32s  %-50s%s\n" "$BOLD" "Agent" "Time" "Project" "Conversation" "$RESET"

    printf '%s\n' "$meta_raw" |
        sort -t $'\t' -k1,1rn |
        emit_rows |
        head -10 |
        while IFS=$'\t' read -r provider mtime title id project workspace; do
            printf "%-8s  %-19s  %-32s  %-50s\n" \
                "$provider" \
                "$(format_time "$mtime")" \
                "${project[1,32]}" \
                "${title[1,50]}"
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

clear

declare provider_color

selection="$(
    printf '%s\n' "$meta_raw" |
    sort -t $'\t' -k1,1rn |
    emit_rows |
    while IFS=$'\t' read -r provider mtime title id project workspace; do
        case "$provider" in
            Claude) provider_color="$ORANGE" ;;
            Codex)  provider_color="$BLUE" ;;
            Grok)   provider_color="$GREEN" ;;
            Cursor) provider_color="$LAVENDER" ;;
            *)      provider_color="$RESET" ;;
        esac

        # Pad each visible column to a fixed width so rows line up —
        # padding happens on the plain text before it's wrapped in
        # ANSI color codes, since color escapes would otherwise throw
        # off printf's width calculation.
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "${provider_color}$(printf '%-8s' "$provider")${RESET}" \
            "$(printf '%-19s' "$(format_time "$mtime")")" \
            "$(printf '%-32s' "${project[1,32]}")" \
            "$title" \
            "$provider" \
            "$id" \
            "$workspace"
    done |
    fzf \
        --ansi \
        --delimiter=$'\t' \
        --with-nth=1,2,3,4 \
        --prompt="Resume> " \
        --height=35 \
        --layout=reverse \
        --header="$(printf '%-8s\t%-19s\t%-32s\tConversation' "Agent" "Time" "Project")" \
        --footer=$'↑↓ navigate  |  ENTER resume  |  ESC quit'
)"

[[ -n "$selection" ]] || exit 0

IFS=$'\t' read -r _ _ _ title provider session workspace <<< "$selection"

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
