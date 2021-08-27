# FLEX
neofetch

#ALIAS
alias mvim='open -a MacVim.app $1'
alias ls='lsd'
alias rclonegui='rclone rcd --rc-web-gui --rc-user=admin --rc-pass=pass --rc-serve'

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
