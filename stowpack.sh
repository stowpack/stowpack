#!/bin/bash

mkdir -p ~/.stowpack

# A basic package manager in pure bash
BOLD=$(tput bold)
DIM=$(tput dim)
RESET=$(tput sgr0)

# Install the YAML parser as a function
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Get the variables
eval $(parse_yaml ~/.stowpack/config)

# Functions
function stcli_install {
  # Loop through every folder in $stowpack_home/bowls
  for folder in "$stowpack_home"/bowls/*; do
    # Check if the folder is actually a folder
    if [[ -d "$folder" ]]; then
      # Check if the folder name matches the argument
      if [[ $(basename "$folder") == "$1" ]]; then
        # Check if the folder contains a file called stowpack.yaml
        if [[ -f "$folder"/stowpack.yaml ]]; then
          # Evaluate the output of parse_yaml as a bash script
          eval "$(parse_yaml "$folder"/stowpack.yaml)"
          echo "$BOLD${1}:$RESET $stowpack_pkg_description"
          # Return the exit code of the last command
          return $?
        fi
      fi
    fi
  done
  # If no results are found, echo a message and run stcli_search
  echo "Could not find $1. Similar matches:"
  stcli_search "$1"
  return 1
}

function stcli_help {
    echo "                                                
  -_-/    ,                                ,,   
 (_ /    ||        ;              _        ||   
(_ --_  =||=  /'\\\\ \\\\/\\/\\ -_-_   < \\,  _-_ ||/\\ 
  --_ )  ||  || || || | | || \\\\  /-|| ||   ||_< 
 _/  ))  ||  || || || | | || || (( || ||   || | 
(_-_-    \\\\, \\\\,/  \\\\/\\\\/ ||-'   \\/\\\\ \\\\,/ \\\\,\\ 
                          |/                    
                          '                     " | lolcat || echo "                                                
  -_-/    ,                                ,,   
 (_ /    ||        ;              _        ||   
(_ --_  =||=  /'\\\\ \\\\/\\/\\ -_-_   < \\,  _-_ ||/\\ 
  --_ )  ||  || || || | | || \\\\  /-|| ||   ||_< 
 _/  ))  ||  || || || | | || || (( || ||   || | 
(_-_-    \\\\, \\\\,/  \\\\/\\\\/ ||-'   \\/\\\\ \\\\,/ \\\\,\\ 
                          |/                    
                          '                     "
    echo
    echo -e "${BOLD}Usage:${RESET} $0 command ${DIM}[--options ..] [arguments]${RESET}"
    echo
    echo -e "${BOLD}Commands:${RESET}"
    echo -e "install\t\tinstall one or more packages."
    echo -e "uninstall\tuninstall one or more packages."
    echo -e "update\t\tupdate the repositories."
    echo -e "help\t\tprint this message."
}

# Check the number of arguments
if [ $# -eq 0 ]; then
    if [ $stowpack_require_command == "true" ]; then
      echo "Please provide a command, or run \`stowpack help\` for help."
      exit 1
    fi
    stcli_help
    exit 1
fi

# Get the first argument
command=$1

# Execute the command
case $command in
    install)
        shift
        for pkg in $@; do
           stcli_install $pkg
        done
        exit $?
        ;;
    uninstall)
        stcli_uninstall $2
        ;;
    help)
        stcli_help
        ;;
    path)
        echo "export PATH=\"\$PATH:$stowpack_home/bin:$stowpack_home/sbin\""
        echo "export MANPATH=\"\$MANPATH/$stowpack_home/man\""
        ;;
    woofwoof)
        echo "     |\\_/|                  
     | o o   They jumped over me, a lazy dog. 
     |   <>              _  
     |  _/\\------____ ((| |))
     |               \`--' |   
 ____|_       ___|   |___.' 
/_/_____/____/_______|"
        ;;
    *)
        echo "$1: Invalid command, see \`stowpack help\`."
        exit 1
esac
