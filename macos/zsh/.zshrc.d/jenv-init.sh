
jenv_home="$HOME/.jenv"
if [[ -d "$jenv_home" ]]
then
  eval "$(jenv init -)"
fi
