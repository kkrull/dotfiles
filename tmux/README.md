# `tmux` dotfiles

## Compatibility

### MacOS Terminal

In Terminal.app, make sure:

- Keyboard sends Option key as Meta
- `$TERM` is set to `xterm-256color` as in:
  - the default profile
  - the [Solarized
    Profiles](https://github.com/altercation/solarized/tree/master/osx-terminal.app-colors-solarized/xterm-256color)

## Task Automation

### `make install`

Make a symbolic link to this one that Tmux will recognize.

### `make uninstall`

Remove `.tmux.conf` in your home directory.
