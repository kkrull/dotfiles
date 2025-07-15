
if ! type terraform >/dev/null
then
  return 0
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
