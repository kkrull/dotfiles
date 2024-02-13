#!/usr/bin/env zsh

set -e

if (( $# != 1 ))
then
  echo "Usage: $0 <Obsidian Notes path>"
  echo "Example [note]: $0 ~/notes/README.md"
  echo "Example [vault]: $0 ~/notes"
  exit 1
fi

relative_path="$1"

absolute_path=$(realpath "$relative_path")
obsidian_uri="obsidian://$absolute_path"

echo "Opening: $obsidian_uri"
exec open "$obsidian_uri"
