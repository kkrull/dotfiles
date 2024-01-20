
if type direnv >/dev/null
then
  ## direnv with nvm
  if [[ -d "$HOME/.nvm/versions/node" ]]
  then
    #https://github.com/direnv/direnv/wiki/Node#export-path
    #https://stackoverflow.com/a/44443016/112682
    export NODE_VERSIONS=$HOME/.nvm/versions/node
    export NODE_VERSION_PREFIX=v
  fi

  eval "$(direnv hook zsh)"
fi
