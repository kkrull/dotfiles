
# Default use of /dev/tty is incompatible with GPG, to prompt for passphrase.
# Results in: `gpg: signing failed: Inappropriate ioctl for device.`
# https://www.gnupg.org/(it)/documentation/manuals/gnupg/Common-Problems.html
GPG_TTY=$(tty)
export GPG_TTY
