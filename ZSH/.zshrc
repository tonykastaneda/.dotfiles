# FLEX
neofetch

#ALIAS
alias mvim='open -a MacVim.app $1'
alias ls='lsd'
alias rclonegui='rclone rcd --rc-web-gui --rc-user=admin --rc-pass=pass --rc-serve'
alias o='~/.zsh/Plugins/launcher.zsh'
alias ca='read input; read output; for f in *.$input; do ffmpeg -i "$f" -c:a $output "${f%.*}.$output"; done'
alias yboff='brew services stop yabai'
alias ybon='brew services start yabai'
alias ybre='brew services restart yabai'
alias skhdre='brew services restart skhd'
alias swd='open .'

#PLUGINS
source ~/.zsh/Plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/Plugins/web-search.plugin.zsh


#PROMPT
setopt PROMPT_SUBST
PROMPT='  ばかげた性交 ${PWD/#$HOME/ ➤  } '

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Add this to your .bashrc, .zshrc or equivalent.
# Run 'fff' with 'f' or whatever you decide to name the function.
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

source ~/.zsh/Plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/usr/local/sbin:$PATH"
