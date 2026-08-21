# Startup
time fastfetch

# Paths
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Aliases
alias rc='zed ~/.zshrc'

alias code='zed .'
alias cunt='cursor . --classic'
alias agent='cursor-agent'
alias fuckit='claude --dangerously-skip-permissions'
alias fuckme='codex --dangerously-bypass-approvals-and-sandbox'

alias logs='git log --oneline --graph --decorate'
alias ranch='git branch -a'
alias swanch='git switch'
alias lit='cd ~/Documents/GitHub'

alias t='touch'
alias owd='open .'
alias lsd='lsd -1'

alias py='python3'
alias makepyenv='python3 -m venv .venv'
alias pyenv='source .venv/bin/activate'



# Plugins
alias plugins='open ~/.zsh/Plugins/'

source ~/.zsh/Plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/.zsh/Plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/Plugins/kali-like.zsh
source ~/.zsh/Plugins/fzf/fzf.zsh
source ~/.zsh/Plugins/gfla-pricing.zsh
source ~/.zsh/Plugins/agents.zsh
source ~/.zsh/Plugins/hd.zsh
source ~/.zsh/Plugins/app-search.zsh

alias tb='terminal-browser'
alias vs='tode'

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# opencode
export PATH=/Users/tonycastaneda/.opencode/bin:$PATH
