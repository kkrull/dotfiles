
PYENV_HOME="$HOME/.pyenv"
if [[ -d "$PYENV_HOME" ]]
then
  export PYENV_HOME
  path=("$PYENV_HOME/bin" "$PYENV_HOME/shims" $path)
fi
