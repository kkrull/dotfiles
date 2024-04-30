
case "$(uname -s)" in
'Darwin')
  # MacOS is already running ssh-agent
  ;;

*)
  # Wait until I'm good and ready, to unlock my key
  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ssh-agent#lazy
  zstyle :omz:plugins:ssh-agent lazy yes
  plugins+=(ssh-agent)
  ;;
esac
