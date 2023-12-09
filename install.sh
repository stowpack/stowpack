#!/bin/bash
function stowpack_config {
  echo "# Configuration for stowpack. Read https://tylerms887.github.io/stowpack/config"
  echo "# for more information on using stowpack configuration."
  echo
  echo "# Where stowpack is located. DON'T CHANGE THIS!"
  echo "stowpack_home: ~/.stowpack"
  echo "# If this value is set to true, running stowpack without any arguments will not"
  echo "# display help info, but return an error."
  echo "stowpack_require_command: false"
}
echo "* Creates ~/.stowpack, ~/.stowpack/bin, ~/.stowpack/sbin"
echo "* Clones the Stowpack repository to ~/.s/source/stowpack"
echo "* Links ~/.s/s/stowpack/stowpack.sh to ~/.s/b/stowpack"
echo "Please press Ctrl+C to cancel the installation."
secs=10
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
# Make a folder for stowpack
echo "==> Creating Stowpack folders..."
mkdir -p ~/.stowpack/source
mkdir -p ~/.stowpack/bin
mkdir -p ~/.stowpack/sbin
# Clone the stowpack repository
echo "==> Collecting Stowpack from GitHub..."
git clone -s https://github.com/TylerMS887/stowpack ~/.stowpack/source/stowpack
# Link the binary
echo "==> Installing Stowpack..."
ln -s ~/.stowpack/source/stowpack/stowpack.sh ~/.stowpack/bin/stowpack
chmod +x ~/.stowpack/source/stowpack/stowpack.sh
# Create a config file
echo "==> Making a Stowpack configuration file..."
stowpack_config > ~/.stowpack/config
# Install stowpack-provided bash
echo "==> Installing Stowpack's bash..."
$BASH ~/.stowpack/stowpack.sh install stowbash
# Print a success message
echo "==> Installation completed!"
echo "Next steps:"
echo "  * Add Stowpack to your path by running: $BASH ~/.stowpack/bin/stowpack path"
echo "  * Install gcc by running $BASH ~/.stowpack/bin/stowpack install gcc"
echo "  * Modify your configuration with: ${EDITOR:-vi} ~/.stowpack/config"
