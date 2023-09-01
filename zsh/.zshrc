HISTFILE=~/.histfile
HISTSIZE=2048
SAVEHIST=2048
bindkey -v

zstyle :compinstall filename '/home/sam/.zshrc'
autoload -Uz compinit
compinit

# Oh my ZSH
#
ZSH_THEME="fino-time"
source /usr/share/oh-my-zsh/oh-my-zsh.sh
plugins=(
	git
	archlinux
)

# Personal
#
alias ll="ls -lha"
alias vim=nvim

export EDITOR=nvim
