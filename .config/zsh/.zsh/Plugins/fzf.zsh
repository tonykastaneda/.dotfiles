# FZF
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# Functions
fs() {
    local extension="${1:-*}"
    local action="${2:-dir}"
    local selected_file

    selected_file=$(
        find . -type f -name "*.${extension}" | fzf --exact
    )

    [[ -z "$selected_file" ]] && return

    if [[ "$action" == "open" ]]; then
        open "$selected_file"
    else
        open "$(dirname "$selected_file")"
    fi
}
