
if ! type direnv >/dev/null
then
  return 0
fi

## direnv with nvm
#https://github.com/direnv/direnv/wiki/Node#export-path
#https://stackoverflow.com/a/44443016/112682
if [[ -d "$HOME/.nvm/versions/node" ]]
then
  export NODE_VERSIONS="$HOME/.nvm/versions/node"
  export NODE_VERSION_PREFIX=v
elif [[ -d "$XDG_CONFIG_HOME/nvm/versions/node" ]]
then
  export NODE_VERSIONS="$XDG_CONFIG_HOME/nvm/versions/node"
  export NODE_VERSION_PREFIX=v
fi

eval "$(direnv hook zsh)"
