#!/usr/bin/env zsh

set -e

self_dir=$(dirname "$0")

local_bin="$HOME/bin"
echo "+directory: $local_bin"
mkdir -p "$local_bin"

scripts_dir=$(realpath "$self_dir/scripts")
for f in "$scripts_dir"/*.sh
do
  f_name=$(basename "$f")
  link_path="$local_bin/${f_name:r}"
  script_path=$(realpath "$f")
  echo "+link: $link_path -> $script_path"
  ln -f -s "$script_path" "$link_path"
done
