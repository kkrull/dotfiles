#Git aliases to show ANSI color codes correctly
alias gl='git log --oneline'
alias gls='git log --oneline -3'
alias glt='LESS=$LESS"S" git log --oneline --graph --decorate --all'
alias glt1='LESS=$LESS"S" git log --oneline --graph --decorate'
alias gd="git diff --word-diff=color --word-diff-regex='[A-z0-9_]+|[^[:space:]]'"
alias glso='git ls-files -o --exclude=*.iml --exclude=.idea'
alias ppath="tr ':' '\n' <<< \"$PATH\""
