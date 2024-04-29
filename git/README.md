# `git` dotfiles

## Installation

```sh
ln -s $(git rev-parse --show-toplevel)/git/gitconfig "$HOME/.gitconfig"
ln -s $(git rev-parse --show-toplevel)/git/gitignore "$HOME/.gitignore"
```

## Removal

```sh
function preserve_original() {
  for source in "$@"
  do
    local target="$1.orig"
    [ ! -f "$source" ] || mv "$source" "$target"

    shift
  done
}

rm -f "$HOME/.gitconfig.orig" "$HOME/.gitignore.orig"
preserve_original "$HOME/.gitconfig" "$HOME/.gitignore"
rm -f "$HOME/.gitconfig" "$HOME/.gitignore"
```
