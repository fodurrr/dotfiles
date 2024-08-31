export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"

autoload -Uz compinit
compinit

setopt HIST_IGNORE_ALL_DUPS

# Devbox
DEVBOX_NO_PROMPT=true

# Completions
source <(devbox completion zsh)
#source <(docker completion zsh)
source <(kubectl completion zsh)

# Starship
eval "$(starship init zsh)"

# The Fuck
#eval $(thefuck --alias)

# Zoxide
#eval "$(zoxide init --cmd cd zsh)"

eval "$(teller sh)"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Zsh plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-syntax-highlighting
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
zstyle ':completion:*' menu yes select

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Aliases
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'


alias vim='nvim'

alias cat='bat --paging never --theme DarkNeon --style plain'
alias fzfp='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

alias ls='eza --icons --git'
alias l='eza --icons --git'
alias la='eza --long --all --header --icons --git'
alias lt='eza --icons --git --tree --level=2'
alias lta='eza --all --icons --git --tree --level=2'

alias tl="task --list-all"
alias t="task"
alias k="kubectl"

alias nio="ni --prefer-offline"
alias s="nr start"
alias d="nr dev"
alias b="nr build"
alias bw="nr build --watch"
alias t="nr test"
alias tu="nr test -u"
alias tw="nr test --watch"
alias w="nr watch"
alias p="nr play"
alias c="nr typecheck"
alias lint="nr lint"
alias lintf="nr lint --fix"
alias release="nr release"
alias re="nr release"

# Use github cli
# alias git=gh

# Go to project root
alias grt='cd "$(git rev-parse --show-toplevel)"'

alias gs='git status'
alias gp='git push'
alias gpf='git push --force'
alias gpft='git push --follow-tags'
alias gpl='git pull --rebase'
alias gcl='git clone'
alias gst='git stash'
alias grm='git rm'
alias gmv='git mv'

alias main='git checkout main'

alias gco='git checkout'
alias gcob='git checkout -b'

alias gb='git branch'
alias gbd='git branch -d'

alias grb='git rebase'
alias grbom='git rebase origin/master'
alias grbc='git rebase --continue'

alias gl='git log'
alias glo='git log --oneline --graph'

alias grh='git reset HEAD'
alias grh1='git reset HEAD~1'

alias ga='git add'
alias gA='git add -A'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git add -A && git commit -m'
alias gfrb='git fetch origin && git rebase origin/master'

alias gxn='git clean -dn'
alias gx='git clean -df'

alias gsha='git rev-parse HEAD | pbcopy'

alias ghci='gh run list -L 1'


function glp() {
  git --no-pager log -$1
}

function gd() {
  if [[ -z $1 ]] then
    git diff --color | diff-so-fancy
  else
    git diff --color $1 | diff-so-fancy
  fi
}

function gdc() {
  if [[ -z $1 ]] then
    git diff --color --cached | diff-so-fancy
  else
    git diff --color --cached $1 | diff-so-fancy
  fi
}

# -------------------------------- #
# Directories
#
# I put
# `~/dev` for my projects
# `~/f` for forks
# `~/r` for reproductions
# -------------------------------- #

function dev() {
  cd ~/dev/$1
}

function repros() {
  cd ~/r/$1
}

function forks() {
  cd ~/f/$1
}

function pr() {
  if [ $1 = "ls" ]; then
    gh pr list
  else
    gh pr checkout $1
  fi
}

function dir() {
  mkdir $1 && cd $1
}

function clone() {
  if [[ -z $2 ]] then
    gh clone "$@" && cd "$(basename "$1" .git)"
  else
    gh clone "$@" && cd "$2"
  fi
}


# Clone to ~/i and cd to it
function clonei() {
  i && clone "$@" && code . && cd ~2
}

function cloner() {
  repros && clone "$@" && code . && cd ~2
}

function clonef() {
  forks && clone "$@" && code . && cd ~2
}

function codei() {
  i && code "$@" && cd -
}

function serve() {
  if [[ -z $1 ]] then
    live-server dist
  else
    live-server $1
  fi
}


