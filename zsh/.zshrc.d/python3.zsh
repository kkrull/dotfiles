
homebrew_path="/opt/homebrew/opt/python@3"
if [[ -d "$homebrew_path" ]]
then
  path=("$homebrew_path/libexec/bin" $path)
fi
