#1/usr/bin/env sh

# This script is based on the following:
# https://gist.github.com/ralph-pichler/3b5ccd7a5c5cd0500e6428752b37e975#file-cashout-sh

DEBUG_API=http://localhost:$PORT
MIN_AMOUNT=1000

function getPeers() {
  curl -s "$DEBUG_API/chequebook/cheque" | jq -r '.lastcheques | .[].peer'
}

function getCumulativePayout() {
  local peer=$1
  local cumulativePayout=$(curl -s "$DEBUG_API/chequebook/cheque/$peer" | jq '.lastreceived.payout')
  if [ $cumulativePayout == null ]
  then
    echo 0
  else
    echo $cumulativePayout
  fi
}

function getLastCashedPayout() {
  local peer=$1
  local cashout=$(curl -s "$DEBUG_API/chequebook/cashout/$peer" | jq '.cumulativePayout')
  if [ $cashout == null ]
  then
    echo 0
  else
    echo $cashout
  fi
}

function getUncashedAmount() {
  local peer=$1
  local cumulativePayout=$(getCumulativePayout $peer)
  if [ $cumulativePayout == 0 ]
  then
    echo 0
    return
  fi

  cashedPayout=$(getLastCashedPayout $peer)
  let uncashedAmount=$cumulativePayout-$cashedPayout
  echo $uncashedAmount
}

function cashout() {
  local peer=$1
  txHash=$(curl -s -XPOST "$DEBUG_API/chequebook/cashout/$peer" | jq -r .transactionHash) 
  if [ "$txHash" == "null" ]
  then
    echo "error while trying to cash the cheque, please check your connection with the swap endpoint" >&2
    return
  fi
  echo cashing out cheque for $peer in transaction $txHash >&2

  result="$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)"
  while [ "$result" == "null" ]
  do
    sleep 5
    result=$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)
  done
}

function cashoutAll() {
  local minAmount=$1
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > $minAmount ))
    then
      echo "uncashed cheque for $peer ($uncashedAmount uncashed)" >&2
      cashout $peer
    fi
  done
}

function listAllUncashed() {
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > 0 ))
    then
      echo $peer $uncashedAmount
    fi
  done
}

main() {
  case "${1}" in
    cashout) cashout $2;;
    cashout-all) cashoutAll $MIN_AMOUNT;;
    list-uncashed|*) listAllUncashed;;
  esac
}

PORT="${PORT:=1635}"
if [ "${1}" != "--crontab" ]; then
  main "${@}"
fi