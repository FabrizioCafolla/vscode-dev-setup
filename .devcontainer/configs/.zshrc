# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/root/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

plugins=(
  git
  github
  python
  pip
  node
  npm
  yarn
  docker
  docker-compose
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
)

setopt PROMPT_SUBST
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git

PROMPT='%F{magenta}%n%f # %2~ %F{green}${vcs_info_msg_0_}%f $ '

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Condividi history tra sessioni
setopt HIST_IGNORE_ALL_DUPS   # Rimuovi duplicati
setopt HIST_FIND_NO_DUPS      # Non mostrare duplicati in ricerca
setopt HIST_REDUCE_BLANKS     # Rimuovi spazi extra

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^ ' autosuggest-accept

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

zstyle ':completion:*' menu select

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
