
# https://go.dev/doc/install, v1.22.4
golang_home="/usr/local/go"
if [[ -d "$golang_home/bin" ]]
then
  path=("$golang_home/bin" $path)
fi
