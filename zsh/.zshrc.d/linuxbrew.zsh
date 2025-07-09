
if [[ ! -d "/home/linuxbrew" ]]
then
  return 0
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
