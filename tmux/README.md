# `tmux` dotfiles

## Task Automation

### `make install`

Back up any existing dotfiles in your home directory, then install symbolic links to these.

### `make remove`

Remove symbolic links to dotfiles in your home directory.

## Compatibility

### MacOS Terminal

In Terminal.app, make sure:

- Keyboard sends Option key as Meta
- `$TERM` is set to `xterm-256color` as in:
  - the default profile
  - the [Solarized
    Profiles](https://github.com/altercation/solarized/tree/master/osx-terminal.app-colors-solarized/xterm-256color)
