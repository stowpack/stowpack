if [[ -n ":$PATH:" == *":$YUMYUM_HOME/bin:"* ]]; then
  echo "Your PATH is missing the yumyum binaries, you should add it."
  echo "To do this, add the following line to ~/.bash_profile and ~/.profile:"
  echo "  export PATH=\"\$PATH:$YUMYUM_HOME/bin\""
fi
