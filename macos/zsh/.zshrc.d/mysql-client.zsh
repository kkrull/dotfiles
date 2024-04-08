
package_dir="/usr/local/opt/mysql-client"
if [[ -d "$package_dir" ]]
then
  path+=("$package_dir/bin")
fi
