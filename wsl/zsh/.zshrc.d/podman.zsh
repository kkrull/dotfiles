
podman_home='/mnt/c/Program Files/RedHat/Podman'
if [[ -d $podman_home ]]
then
  path+=("$podman_home")
  alias docker='podman.exe'
  alias podman='podman.exe'
fi
