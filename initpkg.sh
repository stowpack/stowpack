#!/bin/bash
# This script provides APIs to manipulate the stowpack package manager.
# See the online documentation for details.

function stowpack-install {
  for i in $@; do
    basename="$(basename $i)"
    install -C $i $stowpack_home/$basename
    if $VERBOSE; then
      echo "Installed: $i\t>\t$stowpack_home/$basename"
    fi
  done
}

function stowpack-delete {
  for i in $@; do
    rm $stowpack_home/$i
   if $VERBOSE; then
        echo "Deleted: \t\t$stowpack_home/$i"
   fi
  done
}

function stowpack-force-install {
  for i in $@; do
    basename="$(basename $i)"
    install $i $stowpack_home/$basename
    if $VERBOSE; then
      echo "Force-installed: $i\t>\t$stowpack_home/$basename"
    fi
  done
}

function stowpack-home {
  cd $stowpack_home
}

function stowpack-log {
  echo "[$(date +'%H:%M %d/%m/%g')] $@" >> $stowpack_home/log/recipe.log
  echo "$@"
}
