## Set up xdg directories
if [[ -z $XDG_CONFIG_HOME ]]; then
	export XDG_CONFIG_HOME="$HOME/.config"
fi
if [[ -z $XDG_DATA_HOME ]]; then
	export XDG_DATA_HOME="$HOME/.local/share"
fi
if [[ -z $XDG_CACHE_HOME ]]; then
	export XDG_CACHE_HOME="$HOME/.cache"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~$XDG_DATA_HOME/.histfile
HISTSIZE=10000
SAVEHIST=10000

## Move the main config over to XDG_CONFIG_HOME
# All the settigs should be in there.
source $XDG_CONFIG_HOME/zsh/zshrc
