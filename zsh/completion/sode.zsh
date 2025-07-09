
if ! type sode >/dev/null
then
  return 0
elif ! type register-python-argcomplete >/dev/null
then
  return 0
fi

eval "$(register-python-argcomplete sode)"
