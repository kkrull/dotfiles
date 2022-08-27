# WSL Setup with Debian

## Windows 10

- Enable WSL, if necessary
- Install Debian from the Windows App Store

Command Prompt:

- `wsl -l -v`
  - Make sure it's version 1 not version 2, or internet will not work when
    changing on/off the VPN.
- `wsl --set-default Debian`

### Hyper Terminal

- Install Hyper terminal <https://hyper.io>
- Edit the configuration file:
  - Set `config.shell` to `C:\\Windows\\System32\\wsl.exe`

### Configure Debian

<https://docs.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings>

Start Hyper terminal:

- Create main Linux user when prompted (first time)
- Edit WSL configuration when mounting Windows drives:
  - Edit `/etc/wsl.conf`, not the global WSL configuration file.
  - Set `automount` options to `metadata`
- Re-start WSL completely
  - Hyper: Close
  - Command prompt: `wsl --terminate Debian`
  - Re-start Hyper
- `apt-get update`

### SSH

Hyper terminal:

- `apt-get install ssh`
- Copy or create (`ssh-keygen -t rsa`) SSH keys in `~/.ssh`

### Git and dotfiles

Hyper terminal:

- `apt-get install git`
- `cd $HOME`
- `git clone git@github.com:kkrull/dotfiles.git`
- `git checkout wsl`
- `ln -s ~/dotfiles/wsl/git/gitconfig .gitconfig`

### zsh and oh-my-zsh

<https://ohmyz.sh/#install>

Hyper terminal:

- `apt-get install zsh`
- `chsh /usr/bin/zsh`

Re-start Hyper terminal:

- Create zsh files with admin-recommended settings, when prompted.
- `apt-get install curl`
- `sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
  - from <https://ohmyz.sh/#install>
- Follow the instructions to set up my own `zsh` dotfiles in
  `~/dotfiles/wsl/zsh/`.

### direnv

<https://direnv.net/>

Hyper terminal:

- `apt-get install direnv`
- Re-start Hyper terminal

### tmux

- `apt-get install tmux`
- Follow instructions in `~/dotfiles/wsl/tmux/readme.md`
