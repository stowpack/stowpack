if [[ -n ":$PATH:" == *":$stowpack_home/bin:"* ]]; then
  echo "Your PATH is missing the stowpack binaries, you should add it."
  echo "To do this, add the following line to the shell's init script:"
  echo "  export PATH=\"\$PATH:$stowpack_home/bin\""
fi
