# Dotfiles

You know what to do.  Make symlinks from wherever files need to be to right here.  Then get your groove on.


## bash

Make symlinks for the following:

    $HOME/.bash_aliases -> bash_aliases
    $HOME/.bash_profile -> bash_profile


## bin directory

`bash_profile` adds `$HOME/bin` to your `$PATH`, if it exists.  Make some symlinks in `$HOME/bin` to 
`<this repository>/bin/<useful script>`.  In other words: 

```bash
find-git -> /Users/krull/git/dotfiles/bin/find-git
```


## git

Make a symlink `$HOME/.gitconfig -> gitconfig`.


## tmux

Create a symlink `$HOME/.tmux.conf` -> `tmux.conf`.  On OSX, use `^a + fn + up/down` on the MBP keyboard or `^a + [ + pgup/pgdn` on a PC
keyboard to scroll up and down.  

In OSX Terminal, make sure `$TERM` is set to `xterm-256color` as in the default profile and the 
[Solarized Profiles](https://github.com/altercation/solarized/tree/master/osx-terminal.app-colors-solarized/xterm-256color).


## vim

- Create a symlink `$HOME/.vimrc` -> `<repository>/vimrc`.
- Install [vundle](https://github.com/gmarik/Vundle.vim): ` git clone https://github.com/gmarik/Vundle.vim.git ~/git/vim/bundle/Vundle.vim`
- Open vim and run `:PluginInstall`


## vim in JetBrains IDEs

Symlink `$HOME/.ideavimrc`

