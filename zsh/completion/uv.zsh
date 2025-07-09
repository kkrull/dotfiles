
if ! type uv >/dev/null
then
  return 0
fi

eval "$(uv generate-shell-completion zsh)"
