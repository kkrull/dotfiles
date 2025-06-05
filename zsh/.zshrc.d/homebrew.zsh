if [[ -d /opt/homebrew ]]
then
  # shellcheck disable=SC2206 # not compatible with zsh array-style path
  path=(/opt/homebrew/bin $path)
fi

if type brew &>/dev/null
then
  # must be called before compinit and oh-my-zsh.sh and after homebrew init
  fpath+=("$(brew --prefix)/share/zsh-completions")
fi
