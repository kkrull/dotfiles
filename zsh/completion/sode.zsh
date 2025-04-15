

if ! type sode >/dev/null
then
  return 0
fi

type register-python-argcomplete >/dev/null && eval "$(register-python-argcomplete sode)"
