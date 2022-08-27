# Dotfiles for zsh

It's already installed on OSX, but completions need to be
[installed](https://stackoverflow.com/a/62060648/112682).

This means doing a couple of things.

1. Set `ZDOTDIR` to the path containing this file, by creating `$HOME/.zshenv`
   with [these sole
   contents](https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/):

    ```
    ZDOTDIR=<path to this repo>/zsh
    . $ZDOTDIR/.zshenv
    ```

2. Install the package with `brew install zsh-completions`.

3. Set permissions for completion, as instructed when you install
   `zsh-completions`: `chmod -R go-w "$(brew --prefix)/share"`.
