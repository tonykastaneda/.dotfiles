# FLEX
neofetch

#ALIAS
alias mvim='open -a MacVim.app $1'
alias qq= 'exit'
alias o='open -a'
alias reload='source ~/.zshrc'


#PLUGINS
source ~/.zsh/Plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh



#PROMPT
setopt PROMPT_SUBST
PROMPT='🚽 ${PWD/#$HOME/ ➤  } '

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Add this to your .bashrc, .zshrc or equivalent.
# Run 'fff' with 'f' or whatever you decide to name the function.
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

