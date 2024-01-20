# ZSH for WSL

These directions: https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/

1. Make `$HOME/.zshenv` with contents
    ```shell
     ZDOTDIR=$HOME/dotfiles/wsl/zsh
     . $ZDOTDIR/.zshenv
     ```
2. Make `dotfiles/wsl/zsh/.zshenv`.  It can be empty.



## Instaling NVM as oh-my-zsh plugin

Install tools needed to build node.js <https://github.com/nvm-sh/nvm#important-notes>

```shell
apt-get install build-essential libssl-dev
```

Clone `zsh-nvm` into your custom plugins repo

```shell
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
```

Then load as a plugin in your `.zshrc`

```shell
plugins+=(zsh-nvm)
```

then restart the shell and

```
nvm upgrade
```

