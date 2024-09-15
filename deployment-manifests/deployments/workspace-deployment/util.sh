#!/bin/bash

# Cluster variables
REFERENCEDOMAIN="vera.kumori.cloud"
CLUSTERCERT="cluster.core/wildcard-vera-kumori-cloud"

# Service variables
DEPLOYNAME="user-workspace"

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/user_workspace_service
  ${KAM_CMD} mod dependency salvachillo.dapaas/user_workspace_service/@0.1.0 #../../services/user_workspace_service salvachillo.dapaas/user_workspace_service
  ;;

'create-domain') ;;

'create-secret')
  ${KAM_CMD} ctl register secret dapaas_default_password --from-data "${DEFAULT_PASSWORD}"
  ${KAM_CMD} ctl register secret dapaas_publicKey --from-data "${PUBLIC_SSH_KEY}"
  ${KAM_CMD} ctl register secret dapaas_privateKey --from-data "${PRIVATE_SSH_KEY}"
  ;;

'create-volume') ;;

'deploy')
  ${KAM_CMD} service deploy -t ./ $DEPLOYNAME -- --wait 5m
  ;;

'link')
  ${KAM_CMD} ctl link ${DEPLOYNAME}:access_gateway dapaas:workspace
  ;;

'deploy-all')
  $0 create-domain
  $0 create-secret
  $0 create-volume
  $0 deploy
  $0 link
  ;;

'update')
  $0 create-domain
  $0 create-secret
  $0 create-volume
  ${KAM_CMD} service update -t ./ $DEPLOYNAME -- --wait 5m
  $0 link
  ;;

'describe')
  watch ${KAM_CMD} service describe $DEPLOYNAME
  ;;

'unlink') ;;

'undeploy')
  ${KAM_CMD} service undeploy $DEPLOYNAME -- --wait 5m -f
  ;;

'delete-domain') ;;

'delete-secret')
  ${KAM_CMD} ctl unregister secret dapaas_default_password
  ;;

'delete-volume') ;;

# Undeploy all
'undeploy-all')
  $0 undeploy
  $0 undeploy-inbound
  $0 delete-domain
  $0 delete-secret
  $0 delete-volume
  ;;

*)
  echo "This script doesn't contain that command"
  ;;

esac
