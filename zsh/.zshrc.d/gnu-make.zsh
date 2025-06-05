
#Make auto-complete find targets in included Makefiles
#https://unix.stackexchange.com/a/758032/37734
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets'
