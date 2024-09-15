#!/bin/bash

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/minio_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/minio_component/@0.1.0 # ../../components/minio_component salvachillo.dapaas/minio_component
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
