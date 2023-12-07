if [[ -n ":$PATH:" == *":$STOWPACK_HOME/bin:"* ]]; then
  echo "Your PATH is missing the stowpack binaries, you should add it."
  echo "To do this, add the following line to the init script:"
  echo "  export PATH=\"\$PATH:$STOWPACK_HOME/bin\""
fi
