#!/bin/bash
# This script provides APIs to manipulate the stowpack package manager.
# See the online documentation for details.

function stowpack-install {
  for i in $@; do
    basename="$(basename $i)"
    install -C $i $STOWPACK_HOME/$basename
    if $VERBOSE; then
      echo "Installed: $i\t>\t$STOWPACK_HOME/$basename"
    fi
  done
}

function stowpack-delete {
  for i in $@; do
    rm $STOWPACK_HOME/$i
   if $VERBOSE; then
        echo "Deleted: \t\t$STOWPACK_HOME/$i"
   fi
  done
}

function stowpack-force-install {
  for i in $@; do
    basename="$(basename $i)"
    install $i $STOWPACK_HOME/$basename
    if $VERBOSE; then
      echo "Force-installed: $i\t>\t$STOWPACK_HOME/$basename"
    fi
  done
}

function stowpack-home {
  cd $STOWPACK_HOME
}

function stowpack-log {
  echo "[$(date +'%H:%M %d/%m/%g')] $@" >> $STOWPACK_HOME/log/recipe.log
  echo "$@"
}
