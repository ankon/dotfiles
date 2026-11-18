#!/bin/bash
# usage: brightness.sh <bus> <get|up|down> [step]
BUS=$1; ACTION=$2; STEP=${3:-10}
ERRLOG=/dev/null

get() {
  v=$(ddcutil -b $BUS getvcp 10 2>$ERRLOG | grep -oP 'current value =\s+\K[0-9]+')
  echo ${v:-?}
}

case $ACTION in
  get)  get ;;
  up)   ddcutil -b $BUS setvcp 10 + $STEP 2>$ERRLOG; get ;;
  down) ddcutil -b $BUS setvcp 10 - $STEP 2>$ERRLOG; get ;;
esac

