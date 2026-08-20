#!/usr/bin/env zsh
# ---------------------------------------------------------------
# ragedev.zsh — RAGE dev workspace launcher
# Ghostty 1.3+ (AppleScript API), macOS
#
#   alias RAGE='~/.zsh/Plugins/ragedev.zsh'
#
#   RAGE               -> opens ~/Documents/GitHub/RAGE
#   RAGE RAGE-Intake   -> opens ~/Documents/GitHub/RAGE-Intake
# ---------------------------------------------------------------

REPO_ROOT="$HOME/Documents/GitHub"
PROJECT_DIR="$REPO_ROOT/${1:-RAGE}"
EDITOR_CMD="vim"        # or nvim
SPLIT_CMD="claude --dangerously-skip-permissions"
SPLIT_DIR="right"       # right | left | down | up
NARROW_PX=500           # pixels to shrink the claude pane by; 0 = leave 50/50

# --- sanity checks ---------------------------------------------
if [[ ! -d "$PROJECT_DIR" ]]; then
  print -u2 "ragedev: $PROJECT_DIR does not exist."
  print -u2 "available:"
  ls -1 "$REPO_ROOT" 2>/dev/null | sed 's/^/  /'
  exit 1
fi

cd "$PROJECT_DIR" || exit 1

if [[ "$TERM_PROGRAM" != "ghostty" ]]; then
  print -u2 "ragedev: not running inside Ghostty — opening editor only."
  exec "$EDITOR_CMD" .
fi

if ! osascript -e 'tell application "Ghostty" to get version' >/dev/null 2>&1; then
  print -u2 "ragedev: Ghostty AppleScript unavailable (needs 1.3+). Editor only."
  exec "$EDITOR_CMD" .
fi

# --- create the split, start the sidecar, resize ---------------
osascript <<APPLESCRIPT
tell application "Ghostty"
    set cfg to new surface configuration
    set initial working directory of cfg to "$PROJECT_DIR"

    set leftPane to focused terminal of selected tab of front window
    set rightPane to split leftPane direction $SPLIT_DIR with configuration cfg

    input text "$SPLIT_CMD" to rightPane
    send key "enter" to rightPane

    focus leftPane

    if $NARROW_PX > 0 then
        perform action "resize_split:right,$NARROW_PX" on leftPane
    end if
end tell
APPLESCRIPT

sleep 0.2

# --- editor in this pane ---------------------------------------
exec "$EDITOR_CMD" .
