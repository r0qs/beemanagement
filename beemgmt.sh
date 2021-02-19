#!/bin/bash

INSTALL_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"

start() {
  echo "Enabling and starting timer"
  systemctl enable bee_cashout.timer
  systemctl start bee_cashout.timer
}

stop() {
  echo "Disabling and stoping timer"
  systemctl stop bee_cashout.timer
  systemctl disable bee_cashout.timer
}

install() {
  mkdir -p ${INSTALL_DIR}

  echo "Installing Bee management scripts"
  echo "Installing binary on ${INSTALL_DIR} ..."

  cp dailycash.sh cashout.sh ${INSTALL_DIR}
  chmod +x ${INSTALL_DIR}/dailycash.sh ${INSTALL_DIR}/cashout.sh

  echo "Installing timer service on ${SERVICE_DIR}/bee_cashout.service ..."
  cp ./systemd/bee_cashout.service ${SERVICE_DIR}

  echo "Installing timer trigger on ${SERVICE_DIR}/bee_cashout.timer ..."
  cp ./systemd/bee_cashout.timer ${SERVICE_DIR}

  start
}

uninstall() {
  stop

  echo "Uninstalling Bee management scripts"
  echo "Removing ${INSTALL_DIR}/bee_cashout ..."
  rm -f ${INSTALL_DIR}/bee_cashout

  echo "Removing ${SERVICE_DIR}/bee_cashout.service ..."
  rm -f ${SERVICE_DIR}/bee_cashout.service

  echo "Removing ${SERVICE_DIR}/bee_cashout.timer ..."
  rm -f ${SERVICE_DIR}/bee_cashout.timer
}

usage()
{
  echo "Bee Management Scripts"
  echo ""
  echo "./beemgmt.sh"
  echo "  --help"
  echo "  --install install the cashout scripts (default: ${INSTALL_DIR})"
  echo "  --remove  uninstall the cashout scripts"
  echo "  --start   enable and start the systemd timer"
  echo "  --stop    stop and disable the systemd timer"
  echo ""
}

[[ "$#" -ne 1 ]] && { usage; exit 1; }
while [ "${1}" != "" ]; do
  cmd=`echo ${1} | awk -F= '{print $1}'`
  case $cmd in
    --help)
      usage
      exit
      ;;
    --install)
      install
      ;;
    --remove)
      uninstall
      ;;
    --start)
      start
      ;;
    --stop)
      stop
      ;;
    *)
      echo "ERROR: unknown parameter \"$cmd\""
      usage
      exit 1
      ;;
  esac
  shift
done