#!/bin/zsh
# apps [query] — live app search & launch for macOS (pure shell, no fzf)
#
# Usage:
#   apps
#   apps chrome     # prefill query (optional)
#
# Keys: type to filter · ↑/↓ · Enter launch · Esc/Ctrl-c quit · Tab complete

apps() {
  emulate -L zsh
  setopt extended_glob

  local PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin:${PATH:-}"
  local -a APP_DIRS NAMES PATHS MATCHES
  local QUERY REPLY
  local -i CURSOR=0

  APP_DIRS=(
    /Applications
    $HOME/Applications
    /System/Applications
    /System/Applications/Utilities
  )

  _apps_load() {
    # NOTE: never name a local var `path` — in zsh it is tied to PATH and
    # empties the command search path inside the function.
    local dir line name app_path
    NAMES=()
    PATHS=()
    while IFS= read -r line; do
      name="${line%%$'\t'*}"
      app_path="${line#*$'\t'}"
      NAMES+=("$name")
      PATHS+=("$app_path")
    done < <(
      for dir in $APP_DIRS; do
        [[ -d $dir ]] || continue
        find "$dir" -maxdepth 3 -name '*.app' -type d ! -name '.*' 2>/dev/null
      done | awk -F/ '
        {
          name = $NF
          sub(/\.app$/, "", name)
          path = $0
          score = 2
          if (path ~ /^\/Applications\//) score = 0
          else if (path ~ /^\/Users\//) score = 1
          key = tolower(name)
          if (!(key in seen) || score < scores[key]) {
            seen[key] = name
            paths[key] = path
            scores[key] = score
          }
        }
        END {
          for (k in seen) print seen[k] "\t" paths[k]
        }
      ' | LC_ALL=C sort -f
    )
  }

  _apps_filter() {
    local q="${1:l}" i name
    MATCHES=()
    for i in {1..$#NAMES}; do
      name="${NAMES[$i]:l}"
      if [[ -z $q || $name == *$q* ]]; then
        MATCHES+=($i)
      fi
    done
  }

  _apps_restore() {
    echoti cnorm 2>/dev/null || printf '\033[?25h'
    stty echo icanon 2>/dev/null || true
    printf '\033[0m'
    unfunction _apps_load _apps_filter _apps_restore _apps_draw _apps_read_key 2>/dev/null
  }

  _apps_draw() {
    local rows cols max_list start end i idx name
    rows=${LINES:-$(tput lines 2>/dev/null || echo 24)}
    cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
    max_list=$((rows - 3))
    ((max_list < 1)) && max_list=1

    ((CURSOR < 1)) && CURSOR=1
    (($#MATCHES > 0 && CURSOR > $#MATCHES)) && CURSOR=$#MATCHES

    start=1
    if ((CURSOR > max_list)); then
      start=$((CURSOR - max_list + 1))
    fi
    end=$((start + max_list - 1))
    ((end > $#MATCHES)) && end=$#MATCHES

    printf '\033[H\033[J'
    echoti civis 2>/dev/null || printf '\033[?25l'

    printf 'Apps > %s█  (%d/%d)\n' "$QUERY" $#MATCHES $#NAMES
    printf '%*s\n' "$cols" '' | tr ' ' '─'

    if (($#MATCHES == 0)); then
      print '  (no matches)'
    else
      for ((i = start; i <= end; i++)); do
        idx=$MATCHES[$i]
        name=$NAMES[$idx]
        if ((${#name} > cols - 4)); then
          name="${name[1,cols-7]}..."
        fi
        if ((i == CURSOR)); then
          printf '\033[7m> %s\033[0m\n' "$name"
        else
          printf '  %s\n' "$name"
        fi
      done
    fi
  }

  # Read one key; sets REPLY to: printable | BACKSPACE | ENTER | ESC | UP | DOWN | TAB | CTRL_C
  _apps_read_key() {
    local k
    IFS= read -rsk1 k || return 1
    case $k in
      $'\n'|$'\r') REPLY=ENTER ;;
      $'\t') REPLY=TAB ;;
      $'\x7f'|$'\b') REPLY=BACKSPACE ;;
      $'\x03') REPLY=CTRL_C ;;
      $'\x0e') REPLY=DOWN ;;
      $'\x10') REPLY=UP ;;
      $'\e')
        local rest
        if IFS= read -rsk1 -t 0.05 rest 2>/dev/null; then
          if [[ $rest == '[' ]]; then
            IFS= read -rsk1 rest 2>/dev/null || true
            case $rest in
              A) REPLY=UP ;;
              B) REPLY=DOWN ;;
              *) REPLY= ;;
            esac
          else
            REPLY=ESC
          fi
        else
          REPLY=ESC
        fi
        ;;
      *) REPLY=$k ;;
    esac
  }

  _apps_load
  if (($#NAMES == 0)); then
    print -u2 'No apps found.'
    return 1
  fi

  QUERY=${1:-}
  CURSOR=1
  MATCHES=()

  trap _apps_restore EXIT
  trap '_apps_restore; trap - EXIT; return 130' INT TERM
  stty -echo -icanon 2>/dev/null || true

  _apps_filter "$QUERY"
  _apps_draw

  while _apps_read_key; do
    case $REPLY in
      ENTER)
        if (($#MATCHES > 0)); then
          local app_path=$PATHS[$MATCHES[$CURSOR]]
          _apps_restore
          trap - EXIT INT TERM
          open "$app_path"
          return 0
        fi
        ;;
      ESC|CTRL_C)
        _apps_restore
        trap - EXIT INT TERM
        return 0
        ;;
      BACKSPACE)
        if [[ -n $QUERY ]]; then
          QUERY=${QUERY[1,-2]}
          CURSOR=1
          _apps_filter "$QUERY"
          _apps_draw
        fi
        ;;
      UP)
        if ((CURSOR > 1)); then
          ((CURSOR--))
          _apps_draw
        fi
        ;;
      DOWN)
        if ((CURSOR < $#MATCHES)); then
          ((CURSOR++))
          _apps_draw
        fi
        ;;
      TAB)
        if (($#MATCHES > 0)); then
          QUERY=$NAMES[$MATCHES[$CURSOR]]
          CURSOR=1
          _apps_filter "$QUERY"
          _apps_draw
        fi
        ;;
      '')
        ;;
      *)
        if [[ $REPLY == [[:graph:]] || $REPLY == ' ' ]]; then
          QUERY+="$REPLY"
          CURSOR=1
          _apps_filter "$QUERY"
          _apps_draw
        fi
        ;;
    esac
  done
}
