# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/samuele/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

eval "$(oh-my-posh init zsh --config /usr/share/oh-my-posh/themes/velvet.omp.json)"
plugins=(
	git
	archlinux
)

# Path
#
export PATH=~/.local/bin:$PATH

export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Aliases and env
#
alias ll="ls -lha --color"
export EDITOR=nvim

alias wrenderdoc="WAYLAND_DISPLAY= QT_QA_PLATFORM=xcb qrenderdoc"

# ZVM stuff
export ZVM_INSTALL="$HOME/.zvm/self"
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"

