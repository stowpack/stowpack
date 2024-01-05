tput clear
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
function cleanup() {
    tput cnorm
}

trap cleanup EXIT
echo "                  Welcome to"
echo "  -_-/    ,                                ,,   
 (_ /    ||        ;              _        ||   
(_ --_  =||=  /'\\\\ \\\\/\\/\\ -_-_   < \\,  _-_ ||/\\ 
  --_ )  ||  || || || | | || \\\\  /-|| ||   ||_< 
 _/  ))  ||  || || || | | || || (( || ||   || | 
(_-_-    \\\\, \\\\,/  \\\\/\\\\/ ||-'   \\/\\\\ \\\\,/ \\\\,\\ 
                          |/                    
                          '                     "
echo "This is a complex process. While it definitely won't brick your system"
echo "it will likely affect usage of existing software bundled with it."
secs=15
stty -echo
tput civis
while [ $secs -gt 0 ]; do
   echo -ne "Press Ctrl+C to cancel before: $secs sec\033[0K\r"
   sleep 1
   : $((secs--))
done
stty echo
tput cnorm
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
mkdir -p ~/.stowpack/bowls
if [ ! -d "~/.stowpack/bowls/main" ]; then
  echo "==> Cooking main bowl."
  if git clone https://github.com/stowpack/main ~/.stowpack/bowls/main; then
  echo "Cooked!"
  echo "==> Installing Stowpack's bash..."
  $BASH ~/.stowpack/bin/stowpack install stowbash
  else
  echo "Error. Continuing without a main bowl."
  fi
fi
# Print a success message
echo "==> Installation completed!"
echo "Next steps:"
echo "  * Add Stowpack to your path by running: $BASH ~/.stowpack/bin/stowpack path"
echo "  * Install gcc by running $BASH ~/.stowpack/bin/stowpack install gcc"
echo "  * Modify your configuration with: ${EDITOR:-vi} ~/.stowpack/config"
