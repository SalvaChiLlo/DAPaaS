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

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/postgres_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/postgres_component/@0.1.0 # ../../components/postgres_component salvachillo.dapaas/postgres_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/grafana_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/grafana_component/@0.1.0 # ../../components/grafana_component salvachillo.dapaas/grafana_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/airflow_service
  ${KAM_CMD} mod dependency salvachillo.dapaas/airflow_service/@0.1.0 # ../../components/airflow_service salvachillo.dapaas/airflow_service

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/vscode_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/vscode_component/@0.1.0 # ../../components/vscode_component salvachillo.dapaas/vscode_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/workspace_manager_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/workspace_manager_component/@0.1.0 # ../../components/workspace_manager_component salvachillo.dapaas/workspace_manager_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/access_gateway_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/access_gateway_component/@0.1.0 # ../../components/access_gateway_component salvachillo.dapaas/access_gateway_component

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/fsync_component
  ${KAM_CMD} mod dependency salvachillo.dapaas/fsync_component/@0.1.0 # ../../components/fsync_component salvachillo.dapaas/fsync_component
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
