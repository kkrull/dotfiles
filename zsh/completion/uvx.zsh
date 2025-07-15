
if ! type uvx >/dev/null
then
  return 0
fi

eval "$(uvx --generate-shell-completion zsh)"
