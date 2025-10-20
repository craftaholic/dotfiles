# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

### Prompt + Plugins
# Disable SSH checking in powerlevel10k (was taking 48ms)
POWERLEVEL9K_DISABLE_GITSTATUS=true
POWERLEVEL9K_DISABLE_SSH=true

DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

### Devbox Shell + Paths
# Cache devbox paths to avoid multiple calls
if [[ ! -f "$HOME/.devbox_cache" ]] || [[ ! -f "$HOME/.devbox_path_cache" ]]; then
  devbox global shellenv > "$HOME/.devbox_cache" 2>/dev/null
  devbox global path > "$HOME/.devbox_path_cache" 2>/dev/null
fi
. "$HOME/.devbox_cache" 2>/dev/null

# Store path for reuse
DEVBOX_PATH=$(cat "$HOME/.devbox_path_cache" 2>/dev/null)

typeset -U path cdpath fpath manpath
path+="${DEVBOX_PATH}/.devbox/nix/profile/default/share/powerlevel10k"
fpath+="${DEVBOX_PATH}/.devbox/nix/profile/default/share/powerlevel10k"

# Use direct paths instead of subshell calls
. "${DEVBOX_PATH}/.devbox/nix/profile/default/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
. "${DEVBOX_PATH}/.devbox/nix/profile/default/share/oh-my-zsh/oh-my-zsh.sh"

# Load these plugins at the end since they're less critical
. "${DEVBOX_PATH}/.devbox/nix/profile/default/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
. "${DEVBOX_PATH}/.devbox/nix/profile/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan,underline"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

### History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
unsetopt HIST_IGNORE_ALL_DUPS HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY

### Shell Options + Locale
bindkey -v
export LC_ALL="en_US.UTF-8"
export PATH="$PATH:$HOME/go/bin"
export GOBIN="$HOME/go/bin"
export dry="--dry-run=client -o yaml"

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

### Optional local env
[[ -f ~/.env ]] && . ~/.env

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || . ~/.p10k.zsh
