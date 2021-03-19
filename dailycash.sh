#!/bin/sh

CASHOUT_THRESHOLD=5
source ./cashout.sh --crontab

function givememoney() {
  local n=0
  local list=($(listAllUncashed))
  for (( i=0; i<${#list[@]}; i+=2 ))
  do
    n=$(( n + 1 ))
  done
  if ((n >= ${CASHOUT_THRESHOLD})); then
    cashoutAll ${MIN_AMOUNT}
  fi
}

givememoney