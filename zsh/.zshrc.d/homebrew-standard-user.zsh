homebrew_home="$HOME/opt/homebrew"
if [[ -d "$homebrew_home" ]]
then
  path+=("$homebrew_home/bin")
fi

if type brew &>/dev/null
then
  # must be called before compinit and oh-my-zsh.sh and after homebrew init
  fpath+=("$(brew --prefix)/share/zsh-completions")
fi
