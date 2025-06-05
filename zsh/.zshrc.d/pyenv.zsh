
PYENV_HOME="$HOME/.pyenv"
if [[ -d "$PYENV_HOME" ]]
then
  export PYENV_HOME
  # shellcheck disable=SC2206 # not compatible with zsh array-style path
  path=("$PYENV_HOME/bin" "$PYENV_HOME/shims" $path)
fi
