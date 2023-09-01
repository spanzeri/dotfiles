# DotFiles

Those are my personal dotfiles for archlinux with Hyprland.

It includes my nvim config as well.

## Usage

Those dotfiles are structured as to be easy to setup using stow.

For every subdirectory you need, you can run:
```
stow -t /home/<user> <app-name>
```

This will create a symlink with the appropriate subdirectory structure.

Make sure you backup and move your own configs before.


## NOTE

This is a rough first pass and both directories and individul config are likely to change.

Also note that those are not very tested and might not work for you.

Lastly, those config have been created for a NVIDIA GPU on real hardware (desktop). You'll need to adjust a few things for this to run in a VM or on different hardware.

See the arch and hyprland wiki pages for NVIDIA.
