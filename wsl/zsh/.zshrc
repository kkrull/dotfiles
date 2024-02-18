function source_module() {
  local name="$1"
  local module_path="$2"

  printf "+%s: " "$name"
  source "$module_path" && echo "OK" || echo "FAIL"
}

function run_initializer() {
  local name="$1"
  local script="$2"

  printf "+%s: " "$name"
  "$script" && echo "OK" || echo "FAIL"
}

## Main

# Updates to fpath (tab completion) and path
# source_module "chruby" "$ZDOTDIR/.zshrc.d/chruby.zsh"
# source_module "dotnet" "$ZDOTDIR/.zshrc.d/dotnet.zsh"
source_module "git" "$ZDOTDIR/.zshrc.d/git.zsh"
# source_module "homebrew" "$ZDOTDIR/.zshrc.d/homebrew.zsh"
# source_module "jenv" "$ZDOTDIR/.zshrc.d/jenv.zsh"
source_module "less" "$ZDOTDIR/.zshrc.d/less.zsh"
source_module "nvm" "$ZDOTDIR/.zshrc.d/nvm.zsh"
source_module "oh-my-zsh" "$ZDOTDIR/.zshrc.d/oh-my-zsh.zsh"
source_module "podman" "$ZDOTDIR/.zshrc.d/podman.zsh"
# source_module "sfdx" "$ZDOTDIR/.zshrc.d/sfdx.zsh"
source_module "ssh-agent" "$ZDOTDIR/.zshrc.d/ssh-agent.zsh"
source_module "zsh" "$ZDOTDIR/.zshrc.d/zsh.zsh"

# $plugins dependencies
source "$ZSH/oh-my-zsh.sh"

# $fpath dependencies: https://stackoverflow.com/a/63661686/112682
autoload -Uz compinit
compinit

# compinit dependencies
# run_initializer "jenv initializer" "$ZDOTDIR/.zshrc.d/jenv-init.sh"
# source_module "terraform completions" "$ZDOTDIR/.zshrc.d/terraform-completions.zsh"

# direnv (yes this has to be at the end)
source_module "direnv" "$ZDOTDIR/.zshrc.d/direnv.zsh"
