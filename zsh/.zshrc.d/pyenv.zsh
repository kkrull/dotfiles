
pyenv_home="$HOME/.pyenv"
if [[ -d "$pyenv_home" ]]
then
  path=("$pyenv_home/bin" "$pyenv_home/shims" $path)
fi
