# Dotfiles for zsh

It's already installed on OSX, but completions need to be
[installed](https://stackoverflow.com/a/62060648/112682).

This means doing a few things.

1. Set `ZDOTDIR` to the path containing this file, by creating `$HOME/.zshenv` with [these sole
  contents](https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/):

    ```
    ZDOTDIR=<path to this repo>/zsh
    . $ZDOTDIR/.zshenv
    ```

2. Install the package with `brew install zsh-completions`.

3. Set permissions for completion, as instructed when you install
  `zsh-completions`: `chmod -R go-w "$(brew --prefix)/share"`.

4. Install `nvm` and `zsh-nvm`

    ```
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
    ```

## Reference

* `nvm`: <https://github.com/nvm-sh/nvm#installing-and-updating>
* `zsh-nvm`: <https://github.com/lukechilds/zsh-nvm>
