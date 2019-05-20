#NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#RVM
export PATH="$PATH:$HOME/.rvm/bin"

#Travis CI (added by travis gem)
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"
