#1/usr/bin/env sh
# This script is based on the following:
# https://gist.github.com/ralph-pichler/3b5ccd7a5c5cd0500e6428752b37e975#file-cashout-sh

DEBUG_API=http://localhost:$PORT
MIN_AMOUNT=1000000000000 # 0.0001gBZZ
MAX_RETRIES=5
FAIL="\033[31;40m"
SUCCESS="\033[32;40m"
WARNING="\033[33;40m"
NONE="\033[0m"

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
    echo "error while trying to cashout the cheque, please check your connection with the swap endpoint" >&2
    return
  fi
  echo cashing out cheque for $peer in transaction $txHash >&2
  local retry=${MAX_RETRIES}
  result="$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)"
  while [ "$result" == "null" ]
  do
    if ((retry == 0)); then
      echo -e "all ${MAX_RETRIES} attempts to cashout cheque for peer $peer in transaction $txHash $FAIL\0failed! Skipping...$NONE" >&2
      return
    fi
    sleep 5
    echo -e "$WARNING\0retrying$NONE tx $txHash due fail with '$result'..." >&2
    retry=$(( retry - 1 ))
    result=$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)
  done
  echo -e "transaction $txHash $SUCCESS\0successfully$NONE executed." >&2
}

function cashoutAll() {
  echo "searching uncashed cheques for node $PORT..." >&2
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > $MIN_AMOUNT ))
    then
      echo "uncashed cheque for $peer ($uncashedAmount uncashed)" >&2
      cashout $peer
      echo "----------------------------------------------------" >&2
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
    cashout-all) cashoutAll;;
    list-uncashed|*) listAllUncashed;;
  esac
}

PORT="${PORT:=1635}"
if [ "${1}" != "--crontab" ]; then
  main "${@}"
fi