
homebrew_path="/opt/homebrew/opt/python@3"
if [[ -d "$homebrew_path" ]]
then
  # shellcheck disable=SC2206 # not compatible with zsh array-style path
  path=("$homebrew_path/libexec/bin" $path)
fi
