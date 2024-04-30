# `zsh` dotfiles

## Compatibility

### Node Version Manager (`nvm`)

Install it with:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
```

#### Documentation

- `nvm`: <https://github.com/nvm-sh/nvm#installing-and-updating>
- `zsh-nvm`: <https://github.com/lukechilds/zsh-nvm>

## Installation

### All Systems

Configure `zsh` to look for its files here, by creating `$HOME/.zshenv` with these sole contents:

```sh
ZDOTDIR=<path to this repo>/zsh
. $ZDOTDIR/.zshenv
```

Source: <https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/>

### MacOS Homebrew

`zsh` is already installed on MacOS, but completions aren't.  Install the package and update
permissions so that it will work:

```sh
brew install zsh-completions
chmod -R go-w "$(brew --prefix)/share"
```

Source: <https://stackoverflow.com/a/62060648/112682>
