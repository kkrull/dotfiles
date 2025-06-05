# `bash` dotfiles for `git-bash`

You can't make symlinks in MinTTY (e.g. Git Bash).  `ln -s` will just copy the file or make a hard
link or do something completely unintuitive.

Copy these files instead.

    $HOME/.bash_aliases -> bash_aliases
    $HOME/.bash_profile -> bash_profile
