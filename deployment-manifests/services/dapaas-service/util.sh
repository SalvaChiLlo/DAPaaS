#!/bin/bash

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/core_service
  ${KAM_CMD} mod dependency salvachillo.dapaas/core_service/@0.1.0 # ../core_service salvachillo.dapaas/core_service

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/dataset_store_service
  ${KAM_CMD} mod dependency salvachillo.dapaas/dataset_store_service/@0.1.0 # ../dataset_store_service salvachillo.dapaas/dataset_store_service
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
