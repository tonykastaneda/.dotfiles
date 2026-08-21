#!/bin/zsh
# hd [dir] — hand a directory off to Herdr.
# Pick a new workspace, or a new tab in an existing one.

hd() {
  setopt localoptions localtraps no_shwordsplit

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print "Usage: hd [dir]"
    print "Hand a directory off to Herdr as a new workspace, or a tab in an existing one."
    return 0
  fi

  if ! command -v herdr >/dev/null 2>&1; then
    print -u2 "hd: herdr not found"
    return 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    print -u2 "hd: python3 is required to parse Herdr workspace data"
    return 1
  fi

  local target
  if (( $# )); then
    if [[ ! -d "$1" ]]; then
      print -u2 "hd: not a directory: $1"
      return 1
    fi
    target="${1:A}"
  else
    target="$PWD"
  fi

  local label="${target:t}"
  local inside=0
  [[ "${HERDR_ENV:-}" == 1 ]] && inside=1

  local workspace_json
  if ! workspace_json="$(herdr workspace list 2>/dev/null)"; then
    if (( inside )); then
      print -u2 "hd: couldn't read Herdr workspaces"
      return 1
    fi
    builtin cd "$target" || return 1
    exec herdr
  fi

  local parsed
  if ! parsed="$(printf '%s' "$workspace_json" | python3 -c '
import json, sys

data = json.load(sys.stdin)
result = data.get("result", data)

if isinstance(result, dict):
    workspaces = result.get("workspaces", [])
elif isinstance(result, list):
    workspaces = result
else:
    workspaces = []

for w in workspaces:
    wid = str(w.get("workspace_id", w.get("id", "")))
    label = str(w.get("label") or w.get("name") or wid)
    if wid:
        print(wid + "\t" + label.replace("\t", " "))
')"; then
    print -u2 "hd: failed to parse Herdr workspace data"
    return 1
  fi

  local -a workspace_rows
  workspace_rows=("${(@f)parsed}")

  local -a ids labels
  ids=("")
  labels=("New Workspace")

  local row
  for row in "${workspace_rows[@]}"; do
    [[ -z "$row" ]] && continue
    ids+=("${row%%$'\t'*}")
    labels+=("${row#*$'\t'}")
  done

  local -i selected=1
  local -i count=${#labels[@]}
  local -i i
  for (( i = 2; i <= count; i++ )); do
    if [[ "${labels[$i]}" == "$label" ]]; then
      selected=$i
      break
    fi
  done

  if [[ ! -t 0 || ! -t 1 ]]; then
    print -u2 "hd: picker needs a tty"
    return 1
  fi

  local -i drawn=0
  local -i menu_lines=0
  local display="${target/#$HOME/~}"

  _hd_cleanup() {
    printf '\e[?25h'
    unfunction _hd_cleanup _hd_erase_menu _hd_draw_menu 2>/dev/null
  }
  _hd_erase_menu() {
    if (( drawn )); then
      printf '\e[%dF\e[J' "$menu_lines"
      drawn=0
    fi
  }
  _hd_draw_menu() {
    if (( drawn )); then
      printf '\e[%dF' "$menu_lines"
    fi
    printf '\e[J'

    local cols=${COLUMNS:-80}
    local header="Herdr — ${display}"
    if (( ${#header} > cols )); then
      header="${header[1,cols-1]}…"
    fi

    print -r -- "$header"
    print
    local i
    for (( i = 1; i <= count; i++ )); do
      if (( i == selected )); then
        printf '\e[7m  › %s  \e[0m\n' "${labels[$i]}"
      else
        printf '    %s\n' "${labels[$i]}"
      fi
    done
    print
    print '↑↓/jk  enter select   q/esc cancel'

    menu_lines=$((count + 4))
    drawn=1
  }

  trap _hd_cleanup EXIT
  trap '_hd_erase_menu; _hd_cleanup; trap - EXIT; return 130' INT TERM

  printf '\e[?25l'
  _hd_draw_menu

  local key rest
  while true; do
    key=''
    if ! IFS= read -rk1 key; then
      _hd_erase_menu
      return 1
    fi

    case "$key" in
      $'\e')
        rest=''
        IFS= read -rk2 -t 0.05 rest 2>/dev/null
        case "$rest" in
          '[A'|'OA')
            (( selected-- ))
            (( selected < 1 )) && selected=$count
            ;;
          '[B'|'OB')
            (( selected++ ))
            (( selected > count )) && selected=1
            ;;
          *)
            _hd_erase_menu
            return 0
            ;;
        esac
        _hd_draw_menu
        ;;
      j)
        (( selected++ ))
        (( selected > count )) && selected=1
        _hd_draw_menu
        ;;
      k)
        (( selected-- ))
        (( selected < 1 )) && selected=$count
        _hd_draw_menu
        ;;
      $'\n'|$'\r')
        _hd_erase_menu
        _hd_cleanup
        trap - EXIT INT TERM

        local create_out
        if (( selected == 1 )); then
          if ! create_out="$(herdr workspace create --cwd "$target" --label "$label" --focus 2>&1)"; then
            print -u2 "hd: failed to create workspace"
            print -u2 "$create_out"
            return 1
          fi
        else
          if ! create_out="$(herdr tab create --workspace "${ids[$selected]}" --cwd "$target" --label "$label" --focus 2>&1)"; then
            print -u2 "hd: failed to create tab"
            print -u2 "$create_out"
            return 1
          fi
        fi

        (( inside )) && return 0
        exec herdr
        ;;
      q|Q)
        _hd_erase_menu
        return 0
        ;;
    esac
  done
}
