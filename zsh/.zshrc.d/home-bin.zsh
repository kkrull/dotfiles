
# Sometimes I install my own links here
home_bin="$HOME/bin"
if [[ -d "$home_bin" ]]
then
  path+=("$home_bin")
fi

# python/pip3 installs stuff here, like pre-commit
local_bin="$HOME/.local/bin"
if [[ -d "$local_bin" ]]
then
  path+=("$local_bin")
fi
