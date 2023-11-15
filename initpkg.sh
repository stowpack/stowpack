#!/bin/bash
# This script provides APIs to manipulate the yumyum package manager.
# See the online documentation for details.

function yumyum-install {
  for i in $@; do
    basename="$(basename $i)"
    install -C $i $YUMYUM_HOME/$basename
    if $VERBOSE; then
      echo "Installed: $i\t>\t$YUMYUM_HOME/$basename"
    fi
  done
}

function yumyum-delete {
  for i in $@; do
    rm $YUMYUM_HOME/$i
   if $VERBOSE; then
        echo "Deleted: \t\t$YUMYUM_HOME/$i"
   fi
  done
}

function yumyum-force-install {
  for i in $@; do
    basename="$(basename $i)"
    install $i $YUMYUM_HOME/$basename
    if $VERBOSE; then
      echo "Force-installed: $i\t>\t$YUMYUM_HOME/$basename"
    fi
  done
}

function yumyum-home {
  cd $YUMYUM_HOME
}

function yumyum-log {
  echo "[$(date +'%H:%M %d/%m/%g')] $@" >> $YUMYUM_HOME/log/recipe.log
  echo "$@"
}
