# # Set up the prompt at the bottom of the terminal
# printf "\e[H\ec\e[${LINES}B"
# alias clear="clear && printf '\e[H\ec\e[${LINES}B'"
#
# print_horizontal_line() {
#     local cols=$(tput cols)  # Get the number of columns in the terminal
#     printf '%*s\n' "$cols" '' | tr ' ' '-'
# }
#
# # Example usage in precmd function
# precmd() {
#     print_horizontal_line
# }

### Instant Prompt (Powerlevel10k) — Keep at the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Devbox Shell + Paths
eval "$(devbox global shellenv)"
typeset -U path cdpath fpath manpath
path+="${(s/:/)$(devbox global path)/.devbox/nix/profile/default/share/powerlevel10k}"
fpath+="${(s/:/)$(devbox global path)/.devbox/nix/profile/default/share/powerlevel10k}"

### Prompt + Plugins
source "$(devbox global path)/.devbox/nix/profile/default/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
source "$(devbox global path)/.devbox/nix/profile/default/share/oh-my-zsh/oh-my-zsh.sh"
source "$(devbox global path)/.devbox/nix/profile/default/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(devbox global path)/.devbox/nix/profile/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=cyan,underline"

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

### TheFuck
eval "$(thefuck --alias)"

### Aliases
alias fnvim='nvim $(fzf --height 40% --preview "bat --color=always --style=numbers {}")'
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
alias note='/Users/tranthang/Library/Mobile Documents/iCloud~md~obsidian/Documents/tommy-note-vault'
alias tera='terraform'

### Kubernetes Completion
source <(kubectl completion zsh)

### Powerlevel10k Prompt Config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

### Google Cloud SDK
[[ -f "$HOME/Documents/projects/development/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/Documents/projects/development/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/Documents/projects/development/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/Documents/projects/development/google-cloud-sdk/completion.zsh.inc"

### Optional local env
[[ -f ~/.env ]] && source ~/.env

### Optional: Clear screen on load
clear

# Added by Windsurf
export PATH="/Users/tranthang/.codeium/windsurf/bin:$PATH"
