## zsh-completions: path completion for homebrew (git et al)
if type brew &>/dev/null
then
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
plugins=(chruby git zsh-nvm)
source $ZSH/oh-my-zsh.sh


## Dotnet

dotnet_home="$HOME/.dotnet"
if [[ -d "$dotnet_home/tools" ]]
then
  path=("$dotnet_home/tools" $path)
  export PATH
fi


## Java

jenv_home="$HOME/.jenv"
if [[ -d "$jenv_home" ]]
then
  path=("$jenv_home/bin" $path)
  eval "$(jenv init -)"
fi


## Less

#Keep less from blanking the screen after exiting
#https://unix.stackexchange.com/questions/38634/is-there-any-way-to-exit-less-without-clearing-the-screen
export LESS='-iXR --shift 2'


## Python

# pyenv with user-local binaries (pipenv)
#if type pyenv >/dev/null
#then
#  eval "$(pyenv init -)"
#  python_user_local="$HOME/.local/bin"
#  if [[ -d "$python_user_local" ]]
#  then
#    path=("$python_user_local" $path)
#    export PATH
#  fi
#fi

# pyenv 2023.08
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


## Salesforce

if type sfdx >/dev/null
then
  export SFDX_AUTOUPDATE_DISABLE='true'
fi


## Terraform

if type terraform >/dev/null
then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/local/bin/terraform terraform
fi


## direnv (yes this has to be at the end)

if type direnv >/dev/null
then
  ## direnv with nvm
  if [[ -d "$HOME/.nvm/versions/node" ]]
  then
    #https://github.com/direnv/direnv/wiki/Node#export-path
    #https://stackoverflow.com/a/44443016/112682
    export NODE_VERSIONS=$HOME/.nvm/versions/node
    export NODE_VERSION_PREFIX=v
  fi

  eval "$(direnv hook zsh)"
fi
