# Portable zsh environment
# Source from $HOME/.zshenv after setting ZDOTDIR.

## Rust

#Migrated from rustup installation in $HOME/.zshenv
if [[ -d "$HOME/.cargo" ]]
then
  if [ -v DOTFILES_SILENT ]
  then
    source "$HOME/.cargo/env"
  else
    printf "+%s: " "rust"
    source "$HOME/.cargo/env" && echo "OK" || echo "FAIL"
  fi
fi
