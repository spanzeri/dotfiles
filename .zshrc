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
HISTFILE=$XDG_DATA_HOME/.histfile
HISTSIZE=10000
SAVEHIST=10000

## Move the main config over to XDG_CONFIG_HOME
# All the settigs should be in there.
source $XDG_CONFIG_HOME/zsh/zshrc

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/sam/.config/.dart-cli-completion/zsh-config.zsh ]] && . /home/sam/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/sam/.lmstudio/bin"
# End of LM Studio CLI section

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

# Pi
export PATH="/home/sam/.pi/agent/bin:$PATH"
# Pi disables inline images under tmux; force kitty graphics when inside kitty.
if [[ -n $KITTY_WINDOW_ID ]]; then
	export PI_IMAGE_PROTOCOL=kitty
fi

# Added by Unsloth setup
export PATH="/home/sam/.local/share/../bin:$PATH"
