
dotnet_home="$HOME/.dotnet"
if [[ -d "$dotnet_home/tools" ]]
then
  path+=("$dotnet_home/tools")
fi
