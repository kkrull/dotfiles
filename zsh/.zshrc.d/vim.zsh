
if [[ -e /opt/homebrew/bin/nvim ]]
then
  export EDITOR=/opt/homebrew/bin/nvim
elif [[ -e /usr/bin/nvim ]]
then
  export EDITOR=/usr/bin/nvim
elif [[ -e /usr/bin/vim ]]
then
  export EDITOR=/usr/bin/vim
fi

if [[ -v EDITOR ]]
then
  if type git >/dev/null
  then
    export GIT_EDITOR="$EDITOR"
  fi
fi
