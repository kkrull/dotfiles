if [[ -d /opt/homebrew ]]
then
  path=(/opt/homebrew/bin $path)
fi

if type brew &>/dev/null
then
  # must be called before compinit and oh-my-zsh.sh and after homebrew init
  fpath+=("$(brew --prefix)/share/zsh-completions")
fi
