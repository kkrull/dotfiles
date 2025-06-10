# Configuration for `zsh`

## Compatibility

### Homebrew (MacOS)

`zsh` is already installed on MacOS, but completions aren't.  Install the package and update
permissions so that it will work:

```sh
brew install zsh-completions
chmod -R go-w "$(brew --prefix)/share"
```

Source: <https://stackoverflow.com/a/62060648/112682>

### Node Version Manager (`nvm`)

Install it with:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
```

Documentation:

- `nvm`: <https://github.com/nvm-sh/nvm#installing-and-updating>
- `zsh-nvm`: <https://github.com/lukechilds/zsh-nvm>

### `zsh-syntax-highlighting`

Install with

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Source: <https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md>

## Environment Variables

### `DOTFILES_SILENT`

Set this in `$HOME/.zshenv`:

- `true`: Suppress log statements when loading modules from `.zshrc.d/`.
- unset: Log which modules are loaded from `.zshrc.d/`.

## Task Automation

### `make install`

Back up any existing `.zshenv` in your home directory, then create a new one that points to here.

Source: <https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/>

### `make remove`

Remove `.zshenv` in your home directory.
