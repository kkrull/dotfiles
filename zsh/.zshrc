
## zsh-completions: path completion for homebrew (git et al)
if type brew &>/dev/null; then
  # must be called before compinit and oh-my-zsh.sh and after homebrew init
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

## oh-my-zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Completion options
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# Auto-update checks
# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13

# Misc configuration
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh


## Less

#Keep less from blanking the screen after exiting
#https://unix.stackexchange.com/questions/38634/is-there-any-way-to-exit-less-without-clearing-the-screen
export LESS='-iXR --shift 2'


## Python

# pyenv with user-local binaries (pipenv)
if type pyenv >/dev/null; then
  eval "$(pyenv init -)"
  python_user_local="$HOME/.local/bin"
  if [[ -d "$python_user_local" ]]
  then
    path=("$python_user_local" $path)
    export PATH
  fi
fi


## Terraform

if type terraform >/dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/local/bin/terraform terraform
fi
