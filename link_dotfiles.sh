#!/bin/bash

# This script creates symlinks for the config file/directories into the correct
# place.
#

DOTFILES_REPO="$(cd "$(dirname "$0")"; pwd)"

LINK=(
    "nvim:.config/nvim"
    "bin/tmuxproj:.local/bin/tmuxproj"
    "kitty:.config/kitty"
    ".tmux.conf:.tmux.conf"
    ".zshrc:.zshrc"
    "zsh:.config/zsh"
    "plasma-workspace:.config/plasma-workspace"
)

DRY_RUN=0

# Parse command line arguments for dry run
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]] || [[ "$arg" == "-n" ]]; then
        DRY_RUN=1
    fi
done

if [ -z "$HOME" ]; then
    echo "HOME is not set"
    exit 1
fi

mkdir -p "$HOME/.local/bin"

for entry in "${LINK[@]}"; do
    SRC="${DOTFILES_REPO}/$(echo "$entry" | cut -d: -f1)"
    DST=$HOME/$(echo "$entry" | cut -d: -f2)
    if [ $DRY_RUN -eq 1 ]; then
        echo "Dry run; Would link: $SRC -> $DST"
        continue
    fi

    if [ -d "$SRC" ]; then
        # Linking a directory
        ln -sfn "$SRC" "$DST"
        echo "Linked directory: $SRC -> $DST"
    elif [ -f "$SRC" ]; then
        # Linking a file
        ln -sf "$SRC" "$DST"
        echo "Linked file:      $SRC -> $DST"
    else
        echo "Warning: source [$SRC] does not exist, skipping!"
    fi
done
