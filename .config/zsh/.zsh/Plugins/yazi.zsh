#!/bin/zsh
# y [path] — launch Yazi and change to its last directory on exit.

y() {
  setopt localoptions no_shwordsplit

  if ! command -v yazi >/dev/null 2>&1; then
    print -u2 "y: yazi not found"
    return 1
  fi

  local cwd_file cwd
  if ! cwd_file="$(mktemp -t yazi-cwd.XXXXXX)"; then
    print -u2 "y: could not create a temporary cwd file"
    return 1
  fi

  command yazi "$@" --cwd-file="$cwd_file"
  local yazi_status=$?

  if [[ -s "$cwd_file" ]]; then
    cwd="$(<"$cwd_file")"
  fi
  command rm -f -- "$cwd_file"

  if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
    builtin cd -- "$cwd" || return 1
  fi

  return "$yazi_status"
}
