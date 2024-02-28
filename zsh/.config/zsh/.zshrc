unsetopt beep
bindkey -e
bindkey -v

# Load my functions
if [[ -f $XDG_CONFIG_HOME/zsh/functions.zsh ]]; then
	source $XDG_CONFIG_HOME/zsh/functions.zsh
else
	echo "Function file is missing. Did you stow you zsh config from dotfiles?"
	return 1
fi

load_plugin "zsh-users" "zsh-syntax-highlighting"
load_plugin "zsh-users" "zsh-autosuggestions"

autoload -Uz compinit
compinit

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

## ZVM stuff
if [[ -d "$HOME/.zvm" ]]; then
	export ZVM_INSTALL="$HOME/.zvm/self"
	export PATH="$PATH:$HOME/.zvm/bin"
	export PATH="$PATH:$ZVM_INSTALL/"
fi

