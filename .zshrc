# Set custom timeouts for Claude Code bash commands
export BASH_DEFAULT_TIMEOUT_MS=600000
export BASH_MAX_TIMEOUT_MS=6000000

export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux64/bin"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

setopt HIST_IGNORE_ALL_DUPS

# Devbox
# DEVBOX_NO_PROMPT=true

# # Completions
# source <(devbox completion zsh)
source <(docker completion zsh)
# source <(kubectl completion zsh)

# Starship
eval "$(starship init zsh)"

# The Fuck
#eval $(thefuck --alias)

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
# zinit snippet OMZP::tmuxinator
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found

# Disable the cursor style feature
# ZVM_CURSOR_STYLE_ENABLED=false
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q


#######################################################
# ZSH Basic Options
#######################################################

setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

#######################################################
# Environment Variables
#######################################################
# export EDITOR=nvim
# export VISUAL=nvim
export EDITOR=nvim visudo
export VISUAL=nvim visudo
export SUDO_EDITOR=nvim
export FCEDIT=nvim
export TERMINAL=alacritty
export BROWSER=com.brave.Browser
if [[ -x "$(command -v bat)" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
	export PAGER=bat
fi

if [[ -x "$(command -v fzf)" ]]; then
	export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
	  --info=inline-right \
	  --ansi \
	  --layout=reverse \
	  --border=rounded \
	  --color=border:#27a1b9 \
	  --color=fg:#c0caf5 \
	  --color=gutter:#16161e \
	  --color=header:#ff9e64 \
	  --color=hl+:#2ac3de \
	  --color=hl:#2ac3de \
	  --color=info:#545c7e \
	  --color=marker:#ff007c \
	  --color=pointer:#ff007c \
	  --color=prompt:#2ac3de \
	  --color=query:#c0caf5:regular \
	  --color=scrollbar:#27a1b9 \
	  --color=separator:#ff9e64 \
	  --color=spinner:#ff007c \
	"
fi

#######################################################
# ZSH Keybindings
#######################################################

bindkey -v
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region
# bindkey ' ' magic-space                           # do history expansion on space
bindkey "^[[A" history-beginning-search-backward  # search history with up key
bindkey "^[[B" history-beginning-search-forward   # search history with down key

#######################################################
# History Configuration
#######################################################

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#######################################################
# Completion styling
#######################################################

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu yes select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes


# Zsh plugins
# zinit light zsh-users/zsh-autosuggestions
# zinit light zsh-users/zsh-history-substring-search
# zinit light zsh-users/zsh-syntax-highlighting
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
# zstyle ':completion:*' menu yes select

# Zoxide
# eval "$(zoxide init --cmd cd zsh)"

eval "$(~/.local/bin/mise activate zsh)"
# eval "$(devbox global shellenv)"

# Aliases
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias vim='nvim'

alias cat='bat --paging never --theme DarkNeon --style plain'
# Check if batcat exists, otherwise use bat
if command -v batcat &> /dev/null; then
    alias bat='batcat'
fi
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

#######################################################
# Add Common Binary Directories to Path
#######################################################

# Add directories to the end of the path if they exist and are not already in the path
# Link: https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
function pathappend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="${PATH:+"$PATH:"}$ARG"
        fi
    done
}

# Add directories to the beginning of the path if they exist and are not already in the path
function pathprepend() {
    for ARG in "$@"
    do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
            PATH="$ARG${PATH:+":$PATH"}"
        fi
    done
}

# y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Add the most common personal binary paths located inside the home folder
# (these directories are only added if they exist)
pathprepend "$HOME/bin" "$HOME/sbin" "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin"

# Check for the Rust package manager binary install location
# Link: https://doc.rust-lang.org/cargo/index.html
pathappend "$HOME/.cargo/bin"

# Add Tmuxifier to path
pathappend "$HOME/.config/tmux/plugins/tmuxifier/bin"

#######################################################
# Aliases
#######################################################

alias c='clear'
alias q='exit'
alias ..='cd ..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Alias for neovim
if [[ -x "$(command -v nvim)" ]]; then
	alias vi='nvim'
	alias vim='nvim'
	alias svi='sudo nvim'
	alias vis='nvim "+set si"'
elif [[ -x "$(command -v vim)" ]]; then
	alias vi='vim'
	alias svi='sudo vim'
	alias vis='vim "+set si"'
fi

# Alias for lsd
if [[ -x "$(command -v lsd)" ]]; then
	alias ls='lsd -F --group-dirs first'
	alias ll='lsd --all --header --long --group-dirs first'
	alias tree='lsd --tree'
fi

# Alias to launch a document, file, or URL in it's default X application
if [[ -x "$(command -v xdg-open)" ]]; then
	alias open='runfree xdg-open'
fi

# Alias to launch a document, file, or URL in it's default PDF reader
if [[ -x "$(command -v evince)" ]]; then
    alias pdf='runfree evince'
fi

# Alias For bat
# Link: https://github.com/sharkdp/bat
if [[ -x "$(command -v bat)" ]]; then
    alias cat='bat'
fi

# Alias for lazygit
# Link: https://github.com/jesseduffield/lazygit
if [[ -x "$(command -v lazygit)" ]]; then
    alias lg='lazygit'
fi

# Alias for FZF
# Link: https://github.com/junegunn/fzf
# if [[ -x "$(command -v fzf)" ]]; then
#     alias fzf='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'
#     # Alias to fuzzy find files in the current folder(s), preview them, and launch in an editor
# 	if [[ -x "$(command -v xdg-open)" ]]; then
# 		alias preview='open $(fzf --info=inline --query="${@}")'
# 	else
# 		alias preview='edit $(fzf --info=inline --query="${@}")'
# 	fi
# fi

# Get local IP addresses
if [[ -x "$(command -v ip)" ]]; then
    alias iplocal="ip -br -c a"
else
    alias iplocal="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
fi

# Get public IP addresses
if [[ -x "$(command -v curl)" ]]; then
    alias ipexternal="curl -s ifconfig.me && echo"
elif [[ -x "$(command -v wget)" ]]; then
    alias ipexternal="wget -qO- ifconfig.me && echo"
fi


#######################################################
# Functions
#######################################################

# Start a program but immediately disown it and detach it from the terminal
function runfree() {
	"$@" > /dev/null 2>&1 & disown
}

# Copy file with a progress bar
function cpp() {
	if [[ -x "$(command -v rsync)" ]]; then
		# rsync -avh --progress "${1}" "${2}"
		rsync -ah --info=progress2 "${1}" "${2}"
	else
		set -e
		strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
		| awk '{
		count += $NF
		if (count % 10 == 0) {
			percent = count / total_size * 100
			printf "%3d%% [", percent
			for (i=0;i<=percent;i++)
				printf "="
				printf ">"
				for (i=percent;i<100;i++)
					printf " "
					printf "]\r"
				}
			}
		END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
	fi
}

# Copy and go to the directory
function cpg() {
	if [[ -d "$2" ]];then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
function mvg() {
	if [[ -d "$2" ]];then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
function mkdirg() {
	mkdir -p "$@" && cd "$@"
}

# Prints random height bars across the width of the screen
# (great with lolcat application on new terminal windows)
function random_bars() {
	columns=$(tput cols)
	chars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
	for ((i = 1; i <= $columns; i++))
	do
		echo -n "${chars[RANDOM%${#chars} + 1]}"
	done
	echo
}

#######################################################
# ZSH Syntax highlighting
#######################################################
# source ~/.config/zsh/zsh-syntax-highlightin-tokyonight.zsh

#######################################################
# Shell integrations
#######################################################

# Set up fzf key bindings and fuzzy completion
# source <(fzf --zsh)

# Zoxide config for zsh plugins 
# eval "$(zoxide init --cmd cd zsh)"


# Tmuxifier config for zsh plugins  
# eval "$(tmuxifier init -)"

function glp() {
  git --no-pager log -$1
}

function gd() {
  if [[ -z $1 ]]; then
    git diff --color | diff-so-fancy
  else
    git diff --color $1 | diff-so-fancy
  fi
}

function gdc() {
  if [[ -z $1 ]]; then
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
  if [[ -z $2 ]]; then
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
  if [[ -z $1 ]]; then
    live-server dist
  else
    live-server $1
  fi
}


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


