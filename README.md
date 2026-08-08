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


## OrcaSlicer — always stow with `--no-folding`

`.config/OrcaSlicer` is a special case: the app writes runtime state (`log/`, `cache/`,
`ota/`, `system/`, `printers/`, `orca_refresh_token.sec`) into the *same* directory as its
settings. Only `user/` (filament/machine/process presets) and `OrcaSlicer.conf` belong in
version control.

If stow folds `.config/OrcaSlicer` into a single directory symlink — which it does on any
machine where that directory does not already exist — the app then writes ~113 MB of logs
and an auth token straight into this repo. Stow with `--no-folding` so only leaf files get
linked:

```
stow --no-folding -t /home/<user> .
```

The `.gitignore` excludes those paths as a second line of defence, but `--no-folding` is
the actual fix. Quit OrcaSlicer before re-stowing.

## NOTE

This is a rough first pass and both directories and individul config are likely to change.

Also note that those are not very tested and might not work for you.

Lastly, those config have been created for a NVIDIA GPU on real hardware (desktop). You'll need to adjust a few things for this to run in a VM or on different hardware.

See the arch and hyprland wiki pages for NVIDIA.
