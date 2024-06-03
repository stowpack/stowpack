#!/bin/bash

# A basic package manager in pure bash
BOLD=$(tput bold)
DIM=$(tput dim)
RESET=$(tput sgr0)

# Install the YAML parser as a function
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|,$s\]$s\$|]|" \
        -e ":1;s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s,$s\(.*\)$s\]|\1\2: [\3]\n\1  - \4|;t1" \
        -e "s|^\($s\)\($w\)$s:$s\[$s\(.*\)$s\]|\1\2:\n\1  - \3|;p" $1 | \
   sed -ne "s|,$s}$s\$|}|" \
        -e ":1;s|^\($s\)-$s{$s\(.*\)$s,$s\($w\)$s:$s\(.*\)$s}|\1- {\2}\n\1  \3: \4|;t1" \
        -e    "s|^\($s\)-$s{$s\(.*\)$s}|\1-\n\1  \2|;p" | \
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)-$s[\"']\(.*\)[\"']$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)-$s\(.*\)$s\$|\1$fs$fs\2|p" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" | \
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]; idx[i]=0}}
      if(length($2)== 0){  vname[indent]= ++idx[indent] };
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) { vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, vname[indent], $3);
      }
   }'
}
# Get the variables
eval $(parse_yaml ~/.stowpack/config)

# Function to emulate typewriting effect
typewriter_effect() {
    local text="$1"
    local delay="$2"

    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo  # Print a newline after the effect completes
}

mkdir -p $stowpack_home/bowls

# Cook the main bowl, because who doesn't need it?
if [ ! -d "$stowpack_home/bowls/main" ]; then
  if git clone https://github.com/stowpack/main $stowpack_home/bowls/main; then
  else
  echo "Error. Continuing without a main bowl."
  fi
fi

# Parser for GitHub repository URLs
function parse_tap_url {
  # Assume the repo name or the full URL is passed as the first argument
  input=$1
  # Check if the input starts with http or https
  if [[ $input =~ ^https?:// ]]; then
    # Return the input as it is
    echo $input
  else
    # Parse the input as a repo name
    # Check if the input contains a slash
    if [[ $input == *"/"* ]]; then
      # Extract the user name and the repo name without the .git extension
      user=$(echo $input | cut -d '/' -f 1)
      name=$(echo $input | cut -d '/' -f 2 | cut -d '.' -f 1)
    else
      # Use "stowpack" as the default user name
      user="stowpack"
      # Extract the repo name without the .git extension
      name=$(echo $input | cut -d '.' -f 1)
    fi
    # Construct the full url using https prefix
    url="https://github.com/$user/bowl-$name.git"
    # Print the url
    echo $url
  fi
}

# Check if a bowl is from the official Stowpack repository
function official_bowl {
  # Assume the repo name or the full URL is passed as the first argument
  input=$1
  # Check if the input starts with http or https
  if [[ $input =~ ^https?:// ]]; then
    # Return the input as it is
    echo $input
  else
    # Parse the input as a repo name
    # Check if the input contains a slash
    if [[ $input == *"/"* ]]; then
      # Extract the user name and the repo name without the .git extension
      user=$(echo $input | cut -d '/' -f 1)
      name=$(echo $input | cut -d '/' -f 2 | cut -d '.' -f 1)
    else
      # Use "stowpack" as the default user name
      user="stowpack"
      # Extract the repo name without the .git extension
      name=$(echo $input | cut -d '.' -f 1)
    fi
    # Come to conclusion, official or not?
    if [[ "$user" == "stowpack" ]]; then
      stowpack_official=yes
    else
      stowpack_official=no
    fi
  fi
}

# Yes or no
function yes_no {
  # Use read command with -n option to read only one character
  # Use -p option to display the prompt message
  # Use -t option to set a timeout in seconds
  # Store the input in a variable called answer
  read -n 1 -p "$1 [y/n]: " -t 10 answer
  # Check the exit status of read command
  # If it is not zero, it means either timeout or error occurred
  # In that case, assume no as the default answer
  if [ $? -ne 0 ]; then
    answer=n
  fi
  # Convert the answer to lowercase
  answer=${answer,,}
  # Check if the answer is y or n
  # Return 0 for yes, 1 for no
  case $answer in
    y) return 0 ;;
    n) return 1 ;;
    # If the answer is neither y nor n, print an error message and exit
    *) echo "Invalid input: $answer" >&2; exit 2 ;;
  esac
}

# Functions
function stcli_update {
  for folder in "$stowpack_home"/bowls/*; do
    if [ -d "$folder" ]; then
      echo "Updating $(basename $folder) tap..."
      cd $folder
      git pull
    fi
  done
  echo "Updated!"
}

function stcli_install {
  stcli_update
  # Loop through every folder in $stowpack_home/bowls
  for folder in "$stowpack_home"/bowls/*; do
    # Check if the folder is actually a folder
    if [[ -d "$folder" ]]; then
        # Check if the folder contains a file called stowpack.yaml
        if [[ -f "$folder"/$1/stowpack.yaml ]]; then
          # Evaluate the output of parse_yaml as a bash script
          eval "$(parse_yaml $folder/stowpack.yaml)"
          echo "$BOLD${1}:$RESET $stowpack_pkg_description"
          if [ ! -d "$stowpack_home/tmp" ]; then
             echo "No temp folder, creating one."
             mkdir "$stowpack_home/tmp"
          fi
          echo "Downloading $stowpack_pkg_url"
          SPID=$RANDOM
          curl -o $stowpack_home/tmp/stowpack-$SPID "$stowpack_pkg_url"
          if [ $stowpack_pkg_url == *.tar.gz ]; then
             tar xzf $stowpack_home/tmp/stowpack-$SPID
          elif [ $stowpack_pkg_url == *.zip ]; then
             unzip $stowpack_home/tmp/stowpack-$SPID -d $stowpack_home/source/$1
          else
             echo "Error: incompatible format."
             echo "Cleaning up..."
             rm $stowpack_home/tmp/stowpack-$SPID
             return 1
          fi
          for i in $stowpack_pkg_binlist_*; do
             ln -s $stowpack_home/source/$1/$i $stowpack_home/bin/$i
             echo "$i > "
          done
          rm $stowpack_home/tmp/stowpack-$SPID
          # Return the exit code of the last command
          return $?
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
                          '                     "
    echo
    echo -e "${BOLD}Usage:${RESET} $0 command ${DIM}[--options ..] [arguments]${RESET}"
    echo
    echo -e "${BOLD}Commands:${RESET}"
    echo -e "install\t\tinstall one or more packages."
    echo -e "uninstall\tuninstall one or more packages."
    echo -e "upgrade\t\tupgrade one or more packages."
    echo -e "cook\t\tcook a bowl, from GitHub or other git repo."
    echo -e "update\t\tupdate taps to the latest version."
    echo -e "help\t\tprint this message."
}

# Check the number of arguments
if [ $# -eq 0 ]; then
    if [ $stowpack_require_command = "true" ]; then
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
        if [ $# -eq 1 ]; then
           echo "🠟 A single target to install."
        else
           echo "🠟 $# targets to install."
        fi
        for pkg in $@; do
           stcli_install $pkg
        done
        echo "All targets installed."
        exit $?
        ;;
    uninstall)
        shift
        if [ $# -eq 1 ]; then
           echo "🠟 A single target to uninstall."
        else
           echo "🠟 $# targets to uninstall."
        fi
        for pkg in $@; do
           stcli_uninstall $pkg
        done
        echo "All targets uninstalled, RIP. :("
        exit $?
        ;;
    cook)
        shift
        if [ $# -eq 1 ]; then
           echo "🍜 A single bowl to cook."
        else
           echo "🍜 $# bowls to cook."
        fi
        for bowl in $@; do
           echo "🍳  $bowl $DIM$(parse_tap_url $bowl)$RESET"
           if [ $stowpack_requireofficial = "true" ]; then
             official_bowl
             if [[ "$bowl_official" = "false" ]]; then
               echo "Can't cook unofficial bowl due to config rules."
               exit 1
             fi
           git clone "$(parse_tap_url $bowl)" "$stowpack_home/bowls/$(basename $bowl)" -q
        done
        echo "$# bowls cooked."
        echo "$newpackages packages added by new bowls."
        exit $?
        ;;
    update)
         stcli_update
         ;;
    help)
        stcli_help
        ;;
    path)
        if [[ -d "~/.omb" ]]; then
          echo "You are already using Bash Attack,"
          echo "you can enable the stowpack plugin instead."
          exit 1
        fi
        echo "export PATH=\"\$PATH:$stowpack_home/bin:$stowpack_home/sbin\"" >> ~/.bashrc
        echo "export MANPATH=\"\$MANPATH/$stowpack_home/man\"" >> ~/.bashrc
        echo "Injected into Bashrc."
        ;;
    woofwoof)
        typewriter_effect "PRINTING DOG PICTURE..." 0.06
        typewriter_effect "This uses Typewriter effect which" 0.02
        typewriter_effect "prints characters with a delay" 0.02
        typewriter_effect "between each other." 0.02
        typewriter_effect "     |\\_/|                  
     | o o
     |   <>              _  
     |  _/\\------____ ((| |))
     |               \`--' |   
 ____|_       ___|   |___.' 
/_/_____/____/_______|" 0.1
        ;;
        echo "This will relive the best of memories."
    *)
        echo "$1: Invalid command, see \`stowpack help\`."
        exit 1
esac
