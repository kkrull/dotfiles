
golang_home_debian="/usr/local/go"
if [[ -d "$golang_home_debian/bin" ]]
then
  # https://go.dev/doc/install, v1.22.4
  path=("$golang_home_debian/bin" "$path")
fi

if type go >/dev/null
then
  # Debian, Homebrew
  # shellcheck disable=SC2128
  path=("$(go env GOPATH)/bin" "$path")
fi
