#!/bin/bash

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
