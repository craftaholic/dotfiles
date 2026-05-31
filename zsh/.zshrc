### Auto-compile Zsh files if they've been modified
# Compile main config files
for file in ~/.zshrc ~/.zshenv ~/.zprofile ~/.zlogin ~/.zlogout; do
  if [[ -f $file ]] && ([[ ! -f ${file}.zwc ]] || [[ $file -nt ${file}.zwc ]]); then
    zcompile $file
  fi
done

# Compile completion dump if it exists
if [[ -f ~/.zcompdump ]] && ([[ ! -f ~/.zcompdump.zwc ]] || [[ ~/.zcompdump -nt ~/.zcompdump.zwc ]]); then
  zcompile ~/.zcompdump
fi

typeset -U path cdpath fpath manpath

source $HOME/.local/share/mise/installs/vfox-craftaholic-vfox-zsh-autosuggestions/vlatest/zsh-autosuggestions.zsh
source $HOME/.local/share/mise/installs/vfox-craftaholic-vfox-zsh-syntax-highlighting/latest/zsh-syntax-highlighting.zsh

### History
HISTSIZE=1000
SAVEHIST=1000
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
unsetopt HIST_IGNORE_ALL_DUPS HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY

### Shell Options + Locale
bindkey -v
export LC_ALL="en_US.UTF-8"
export PATH="$PATH:$HOME/go/bin:$HOME/.local/devtools/java/jdtls/bin:$HOME/.local/bin"
export GOBIN="$HOME/go/bin"
export dry="--dry-run=client -o yaml"

eval "$(mise activate zsh)"

export TERM=tmux-256color

### Aliases
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gs='git status'
alias jh='./mvnw spring-boot:run'

# kubectl shortcuts
alias k='kubectl'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kd='kubectl delete'
alias kds='kubectl describe'
alias ke='kubectl edit'
alias kg='kubectl get'
alias kr='kubectl run'
alias krp='kubectl replace'
alias krpf='kubectl replace --force -f'
alias ksetns='kubectl config set-context --current --namespace'

# tmux
alias ta='tmux attach-session -t'
alias tk='tmux kill-session -t'
alias tka='tmux kill-session -a'
alias tl='tmux ls'
alias tn='tmux new-session -s'

# misc
alias ls='ls -la --color'

# devcontainer
alias dc='devcontainer'
alias dch='echo "dc: devcontainer
dch: show help utils
dci: init devcontainer default config
dcid: init devcontainer with docker config
dce: exec into the devcontainer with zsh
dcu: start the devcontainer
dcur: start the devcontainer and remove existing container if it exists"'
alias dci='mkdir -p .devcontainer && cp -r ~/.template/devcontainer/. .devcontainer/'
alias dce='devcontainer exec zsh'
alias dcu='devcontainer up'
alias dcur='devcontainer up --remove-existing-container'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan,underline"
# ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
# ZSH_AUTOSUGGEST_USE_ASYNC=1

eval "$(starship init zsh)"

# bun completions
[ -s "/home/tomwy/.bun/_bun" ] && source "/home/tomwy/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/home/tomwy/.opencode/bin:$PATH
