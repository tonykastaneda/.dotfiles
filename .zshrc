# FLEX
neofetch

#ALIAS
alias mvim='open -a MacVim.app $1'
alias qq= 'exit'



#PLUGINS
source /Users/tonycastaneda/.zsh/Plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh



#PROMPT
setopt PROMPT_SUBST
PROMPT='🚽 ${PWD/#$HOME/ ➤  } '
