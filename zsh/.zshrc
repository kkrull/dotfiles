function source_module() {
  local name="$1"
  local module_path="$2"

  if [ -v DOTFILES_SILENT ]
  then
    source "$module_path"
  else
    printf "+%s: " "$name"
    source "$module_path" && echo "OK" || echo "FAIL"
  fi
}

function run_initializer() {
  local name="$1"
  local script="$2"

  if [ -v DOTFILES_SILENT ]
  then
    "$script"
  else
    printf "+%s: " "$name"
    "$script" && echo "OK" || echo "FAIL"
  fi
}

## Main

# Updates to fpath (tab completion) and path
# source_module "chruby" "$ZDOTDIR/.zshrc.d/chruby.zsh"
# source_module "dotnet" "$ZDOTDIR/.zshrc.d/dotnet.zsh"
source_module "git" "$ZDOTDIR/.zshrc.d/git.zsh"
source_module "gpg" "$ZDOTDIR/.zshrc.d/gpg.zsh"
source_module "home-bin" "$ZDOTDIR/.zshrc.d/home-bin.zsh"
source_module "homebrew" "$ZDOTDIR/.zshrc.d/homebrew.zsh"
source_module "homebrew (standard user)" "$ZDOTDIR/.zshrc.d/homebrew-standard-user.zsh"
source_module "homebrewdep-go" "$ZDOTDIR/.zshrc.d/homebrewdep-go.zsh"
# source_module "jenv" "$ZDOTDIR/.zshrc.d/jenv.zsh"
source_module "less" "$ZDOTDIR/.zshrc.d/less.zsh"
source_module "linuxbrew" "$ZDOTDIR/.zshrc.d/linuxbrew.zsh"
source_module "mybatis" "$ZDOTDIR/.zshrc.d/mybatis.zsh"
source_module "mysql-client" "$ZDOTDIR/.zshrc.d/mysql-client.zsh"
# source_module "nvm" "$ZDOTDIR/.zshrc.d/nvm.zsh"
# plugins+=(zsh-nvm)
plugins+=(zsh-syntax-highlighting)
source_module "oh-my-zsh" "$ZDOTDIR/.zshrc.d/oh-my-zsh.zsh"
source_module "podman" "$ZDOTDIR/.zshrc.d/podman.zsh"
# source_module "python3" "$ZDOTDIR/.zshrc.d/python3.zsh"
source_module "pyenv" "$ZDOTDIR/.zshrc.d/pyenv.zsh"
source_module "rust" "$ZDOTDIR/.zshrc.d/rust.zsh"
# source_module "sfdx" "$ZDOTDIR/.zshrc.d/sfdx.zsh"
source_module "ssh-agent" "$ZDOTDIR/.zshrc.d/ssh-agent.zsh"
source_module "vim" "$ZDOTDIR/.zshrc.d/vim.zsh"
source_module "work" "$ZDOTDIR/.zshrc.d/work.zsh"
source_module "xdg-basedir" "$ZDOTDIR/.zshrc.d/xdg-basedir.zsh"
source_module "zsh" "$ZDOTDIR/.zshrc.d/zsh.zsh"
#source_module "rn/alias" "$ZDOTDIR/.zshrc.d/rn/alias.zsh"

# $plugins dependencies
source "$ZSH/oh-my-zsh.sh"

# $fpath dependencies: https://stackoverflow.com/a/63661686/112682
printf "+%s: " "compinit"
autoload -Uz compinit
compinit && echo "OK" || echo "FAIL"

## compinit dependencies

source_module "gnu-make" "$ZDOTDIR/.zshrc.d/gnu-make.zsh"

# completions
# shellcheck disable=SC2044 # find -exec doesn't work with functions
for fn in $(find "$ZDOTDIR/completion" -type f)
do
  source_module "${fn:t:r} completions" "$fn"
done

# jenv
if type jenv >/dev/null
then
  printf "+%s: " "jenv (init)"
  eval "$(jenv init -)" #Must be done here, instead of in a separate file

  #VSCode extensions need JDK_HOME to be set
  jenv enable-plugin export > /dev/null \
    && echo "OK" || echo "FAIL"
fi

# nvm
if type nvm >/dev/null
then
  printf "+%s: " "nvm (use)"
  nvm use default && echo "OK" || echo "FAIL"
fi

# oh-my-zsh
unsetopt AUTO_CD

# terraform
# source_module "terraform completions" "$ZDOTDIR/.zshrc.d/terraform-completions.zsh"

## End matter

# direnv (yes this has to be at the end)
source_module "direnv (init)" "$ZDOTDIR/.zshrc.d/direnv.zsh"

# nvm
printf "+%s: " "nvm (init)"
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && echo "OK" || echo "FAIL"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pyenv
if type pyenv >/dev/null
then
  printf "+%s: " "pyenv (init)"
  eval "$(pyenv init - zsh)" && echo "OK" || echo "FAIL"
fi

# SDKMAN! *nix
SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]
then
  printf "+%s: " "sdkman (*nix init)"
  export SDKMAN_DIR
  source "$SDKMAN_DIR/bin/sdkman-init.sh" && echo "OK" || echo "FAIL"
fi

# SDKMAN! Homebrew
if ! type brew &>/dev/null
then
  echo "OK" > /dev/null
elif ! brew list sdkman-cli &>/dev/null
then
  echo "OK" > /dev/null
else
  printf "+%s: " "sdkman (homebrew init)"
  SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
  export SDKMAN_DIR
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] \
    && source "${SDKMAN_DIR}/bin/sdkman-init.sh" \
    && echo "OK" || echo "FAIL"
fi
