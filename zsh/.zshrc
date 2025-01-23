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
source_module "chruby" "$ZDOTDIR/.zshrc.d/chruby.zsh"
source_module "dotnet" "$ZDOTDIR/.zshrc.d/dotnet.zsh"
source_module "git" "$ZDOTDIR/.zshrc.d/git.zsh"
source_module "gpg" "$ZDOTDIR/.zshrc.d/gpg.zsh"
source_module "home-bin" "$ZDOTDIR/.zshrc.d/home-bin.zsh"
source_module "homebrew" "$ZDOTDIR/.zshrc.d/homebrew.zsh"
source_module "homebrew (standard user)" "$ZDOTDIR/.zshrc.d/homebrew-standard-user.zsh"
source_module "homebrewdep-go" "$ZDOTDIR/.zshrc.d/homebrewdep-go.zsh"
source_module "jenv" "$ZDOTDIR/.zshrc.d/jenv.zsh"
source_module "less" "$ZDOTDIR/.zshrc.d/less.zsh"
source_module "mysql-client" "$ZDOTDIR/.zshrc.d/mysql-client.zsh"
source_module "nvm" "$ZDOTDIR/.zshrc.d/nvm.zsh"
plugins+=(zsh-nvm)
source_module "oh-my-zsh" "$ZDOTDIR/.zshrc.d/oh-my-zsh.zsh"
source_module "podman" "$ZDOTDIR/.zshrc.d/podman.zsh"
source_module "pyenv" "$ZDOTDIR/.zshrc.d/pyenv.zsh"
source_module "rust" "$ZDOTDIR/.zshrc.d/rust.zsh"
source_module "sfdx" "$ZDOTDIR/.zshrc.d/sfdx.zsh"
source_module "ssh-agent" "$ZDOTDIR/.zshrc.d/ssh-agent.zsh"
source_module "vim" "$ZDOTDIR/.zshrc.d/vim.zsh"
source_module "zsh" "$ZDOTDIR/.zshrc.d/zsh.zsh"

# $plugins dependencies
source "$ZSH/oh-my-zsh.sh"

# $fpath dependencies: https://stackoverflow.com/a/63661686/112682
autoload -Uz compinit
compinit

# compinit dependencies
if type jenv >/dev/null
then
  eval "$(jenv init -)" #Must be done here, instead of in a separate file
  jenv enable-plugin export > /dev/null #VSCode extensions need JDK_HOME to be set
fi
source_module "terraform completions" "$ZDOTDIR/.zshrc.d/terraform-completions.zsh"

# direnv (yes this has to be at the end)
source_module "direnv" "$ZDOTDIR/.zshrc.d/direnv.zsh"
