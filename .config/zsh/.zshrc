# Startup
time fastfetch

# Paths
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias rc='zed ~/.zshrc'
alias apps='~/.zsh/Plugins/app-search.sh'
alias plugins='open ~/.zsh/Plugins/'

alias code='cursor . --classic'
alias curse='cursor . --classic'
alias fuckit='claude --dangerously-skip-permissions'

alias gitlogs='git log --oneline --graph --decorate'
alias ranch='git branch -a'
alias swanch='git switch'
alias reep='cd ~/Documents/GitHub'
alias reepos='cd ~/Documents/GitHub'

alias t='touch'
alias owd='open .'

alias py='python3'
alias makepyenv='python3 -m venv .venv'
alias pyenv='source .venv/bin/activate'

alias tb='terminal-browser'


# Plugins
source ~/.zsh/Plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/Plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/Plugins/kali-like.zsh
source ~/.zsh/Plugins/fzf.zsh
