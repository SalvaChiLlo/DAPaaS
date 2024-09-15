#!/bin/bash

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/api_gateway_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/api_gateway_component/@0.1.0 # ../../components/api_gateway_component salvachillo.dapaas/api_gateway_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/dapaas_api_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/dapaas_api_component/@0.1.0 # ../../components/dapaas_api_component salvachillo.dapaas/dapaas_api_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/dapaas_ui_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/dapaas_ui_component/@0.1.0 # ../../components/dapaas_ui_component salvachillo.dapaas/dapaas_ui_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/postgres_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/postgres_component/@0.1.0 # ../../components/postgres_component salvachillo.dapaas/postgres_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/dex_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/dex_component/@0.1.0 # ../../components/dex_component salvachillo.dapaas/dex_component

  ${KAM_CMD} mod dependency --delete kumori.systems/builtins/inbound
  ${KAM_CMD} mod dependency kumori.systems/builtins/inbound/@1.3.0
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
