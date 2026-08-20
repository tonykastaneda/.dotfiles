command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Directories to index
FZF_SEARCH_DIRS=(
    "$HOME/Library/CloudStorage/MountainDuck-KineticNAS"
    "$HOME/Library/CloudStorage/GoogleDrive-anthony@kineticsociety.com/Shared drives/GARMENT FACTORY LA"
    "$HOME/Library/CloudStorage/GoogleDrive-tonykastaneda@gmail.com/My Drive"
    "$HOME/Library/CloudStorage/MountainDuck-192.168.31.130–SMB/Kinetic Society"
    "$HOME/Desktop"
    "$HOME/Documents"
    "$HOME/Downloads"
)

# Cache location
FZF_CACHE="$HOME/.dotfiles/.config/zsh/.zsh/Plugins/fzf/fs-index"

# Build Cache
fs-update() {
    mkdir -p "$(dirname "$FZF_CACHE")"

    echo "Building file index..."

    find "${FZF_SEARCH_DIRS[@]}" -type f 2>/dev/null \
        | sort \
        > "$FZF_CACHE"

    echo "Indexed $(wc -l < "$FZF_CACHE") files."
}

# Search Index
fs() {
    local extension="${1:-*}"
    local selected_file

    if [[ ! -f "$FZF_CACHE" ]]; then
        echo "No file index found."
        echo "Run: fs-update"
        return 1
    fi

    if [[ "$extension" == "*" ]]; then
        selected_file=$(
            fzf --exact < "$FZF_CACHE"
        )
    else
        selected_file=$(
            grep -Ei "\.${extension}$" "$FZF_CACHE" | fzf --exact
        )
    fi

    [[ -n "$selected_file" ]] && open "$selected_file"
}
