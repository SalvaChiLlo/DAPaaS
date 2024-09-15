#!/bin/bash

# Cluster variables
REFERENCEDOMAIN="vera.kumori.cloud"
CLUSTERCERT="cluster.core/wildcard-vera-kumori-cloud"

# Service variables
DEPLOYNAME="dapaas"

KAM_CMD="kam"
KAM_CTL_CMD="kam ctl"

CWD=$(pwd)
echo $CWD

API_URL="https://cmc-forge.vera.kumori.cloud/api/nightly"
AUTH_TOKEN="$AUTH_TOKEN_ENV"
CERT="$ABW_CLUSTER_CERT"
KEY="$ABW_CLUSTER_KEY"
CA_CERT="$ABW_CLUSTER_CA"
USER="admin"
APIURI="$ABW_CLUSTER_ADMISSION"
CERT_ESCAPED=$(echo "$CERT" | sed ':a;N;$!ba;s/\n/\\n/g')
KEY_ESCAPED=$(echo "$KEY" | sed ':a;N;$!ba;s/\n/\\n/g')
CA_CERT_ESCAPED=$(echo "$CA_CERT" | sed ':a;N;$!ba;s/\n/\\n/g')
PUBLIC_SSH_KEY_ESCAPED=$(echo "$PUBLIC_SSH_KEY" | sed ':a;N;$!ba;s/\n/\\n/g')
PRIVATE_SSH_KEY_ESCAPED=$(echo "$PRIVATE_SSH_KEY" | sed ':a;N;$!ba;s/\n/\\n/g')

required_vars=(
  "DOCKER_USER"
  "DOCKER_PASSWORD"
  "DOCKER_REGISTRY"
)

# Function to check if a variable is set
check_env_vars() {
  for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
      echo "Error: Environment variable $var is not set."
      exit 1
    fi
  done
}

# Check environment variables
check_env_vars

# set -x
# set -e

case $1 in

'refresh-dependencies')
  ${KAM_CMD} mod dependency --delete kumori.systems/kumori
  ${KAM_CMD} mod dependency kumori.systems/kumori/@1.1.7

  ${KAM_CMD} mod dependency --delete salvachillo.dapaas/dapaas_service
  ${KAM_CMD} mod dependency salvachillo.dapaas/dapaas_service/@0.1.0 #../../services/dapaas_service salvachillo.dapaas/dapaas_service
  ;;

'axebow-prep')
  # Create organization
  echo
  curl -X POST $API_URL/organization/dapaas \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "companyName": "dapaasdapaas",
  "cif": "dapaasdapaas",
  "billing": {
    "country": "dapaasdapaas",
    "region": "dapaasdapaas",
    "city": "dapaasdapaas",
    "address": "dapaasdapaas",
    "zip": "dapaasdapaas"
  }
}'

  # Create tenant under the organization
  echo
  curl -X POST $API_URL/tenant/dapaas \
    echo -------------------------------
  echo "-H "Content"
  echo -------------------------------
  echo
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "organization": "dapaas",
  "registry": {
    "endpoint": "https://registry.npmjs.org",
    "domain": "salvachll.dapaas",
    "credentials": "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",
    "public": true
  },
}'

  # Create an account under the tenant
  echo -------------------------------
  echo" /dapaas \"
  echo -------------------------------
  echo
  echo
  curl -X POST $API_URL/tenant/dapaas/account/dapaas \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "spec": {
    "api": "kumori",
    "apiuri": "'"$APIURI"'",
    "iaasconfig": {},
    "credentials": {
      "method": "mtls",
      "cert": "'"${CERT_ESCAPED}"'",
      "key": "'"${KEY_ESCAPED}"'",
      "ca": "'"${CA_CERT_ESCAPED}"'",
      "user": "'"${USER}"'"
    },
    "marks": {
      "vcpu": { "lowmark": 999999999, "highmark": 999999999 },
      "memory": { "lowmark": 999999999, "highmark": 999999999 },
      "vstorage": { "lowmark": 999999999, "highmark": 999999999 },
      "nrstorage": { "lowmark": 999999999, "highmark": 999999999 },
      "rstorage": { "lowmark": 999999999, "highmark": 999999999 },
      "storage": { "lowmark": 999999999, "highmark": 999999999 },
      "cost": { "lowmark": 0, "highmark": 0 }
    }
  },
  "meta": {
    "labels": {}
  }
}'
  ;;

'create-domain')
  # ${KAM_CMD} ctl register domain dapaas_serverdomain -d ${DEPLOYNAME}.${REFERENCEDOMAIN}
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/domain/dapaas_serverdomain \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "domain",
  "data": {
  "domain": "'"${DEPLOYNAME}.${REFERENCEDOMAIN}"'"
  }
}'

  ;;

'create-secret')

  # ${KAM_CMD} ctl register secret dapaas_googleIdpClientId --from-data "${GOOGLE_IDP_CLIENT_ID}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_googleidpclientid \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${GOOGLE_IDP_CLIENT_ID}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_googleIdpClientSecret --from-data "${GOOGLE_IDP_CLIENT_SECRET}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_googleidpclientsecret \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${GOOGLE_IDP_CLIENT_SECRET}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_default_password --from-data "${DEFAULT_PASSWORD}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_default_password \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${DEFAULT_PASSWORD}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_abwClusterAdmission --from-data "${ABW_CLUSTER_ADMISSION}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_abwclusteradmission \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${ABW_CLUSTER_ADMISSION}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_abwClusterCa --from-data "${ABW_CLUSTER_CA}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_abwclusterca \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${CA_CERT_ESCAPED}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_abwClusterCert --from-data "${ABW_CLUSTER_CERT}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_abwclustercert \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${CERT_ESCAPED}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_abwClusterKey --from-data "${ABW_CLUSTER_KEY}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_abwclusterkey \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${KEY_ESCAPED}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_abwToken --from-data "${ABW_TOKEN}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_abwtoken \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${ABW_TOKEN}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_default_password --from-data "${DEFAULT_PASSWORD}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_default_password \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${DEFAULT_PASSWORD}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_publicKey --from-data "${PUBLIC_SSH_KEY}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_publickey \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${PUBLIC_SSH_KEY_ESCAPED}"'"
  }
}'

  # ${KAM_CMD} ctl register secret dapaas_privateKey --from-data "${PRIVATE_SSH_KEY}"
  echo
  curl -X POST $API_URL/tenant/dapaas/resource/secret/dapaas_privatekey \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "kind": "secret",
  "data": {
  "secret": "'"${PRIVATE_SSH_KEY_ESCAPED}"'"
  }
}'

  ;;

'create-volume') ;;

'deploy')
echo
  curl -X POST $API_URL'/tenant/dapaas/service/dapaas/simple?wait=0&validate=true' \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -k --cert <(echo "$CERT") --key <(echo "$KEY") --cacert <(echo "$CA_CERT") \
    -d '{
  "deployment": {
    "name": "dapaas",
    "up": null,
    "meta": {},
    "config": {
      "parameter": {
        "common": {
          "defaultUser": "admin",
          "imageRegistry": "docker.io",
          "dbNames": ["dapaas"],
          "baseUrl": "https://dapaas.vera.kumori.cloud",
          "cmcUrl": "https://cmc-forge.vera.kumori.cloud/api/nightly"
        },
        "core_srv": {
          "dex": {
            "dexSubpath": "idp",
            "dexDisplayName": "DAPaaS Login"
          },
          "api_gateway": {},
          "dapaas_api": {},
          "dapaas_ui": {},
          "postgres": {}
        },
        "dataset_store_srv": {
          "minio": {}
        }
      },
      "resource": {
        "defaultPassword": {
          "secret": "dapaas_default_password"
        },
        "imageRegistrySecret": {
          "secret": "cluster.core/docker_hub_demo"
        },
        "googleIdpClientId": {
          "secret": "dapaas_googleidpclientid"
        },
        "googleIdpClientSecret": {
          "secret": "dapaas_googleidpclientsecret"
        },
        "abwClusterAdmission": {
          "secret": "dapaas_abwclusteradmission"
        },
        "abwToken": {
          "secret": "dapaas_abwtoken"
        },
        "abwClusterCert": {
          "secret": "dapaas_abwclustercert"
        },
        "abwClusterKey": {
          "secret": "dapaas_abwclusterkey"
        },
        "abwClusterCa": {
          "secret": "dapaas_abwclusterca"
        },
        "servercert": {
          "certificate": "cluster.core/wildcard-vera-kumori-cloud"
        },
        "serverdomain": {
          "domain": "dapaas_serverdomain"
        },
        "minio_vol": {
          "volume": {
            "kind": "storage",
            "size": 5,
            "unit": "G"
          }
        },
        "postgres_vol": {
          "volume": {
            "kind": "storage",
            "size": 5,
            "unit": "G"
          }
        }
      },
      "resilience": 0,
      "scale": {
        "detail": {}
      }
    },
    "artifact": {
      "spec": [1, 0],
      "ref": {
        "version": [0,1,0],
        "name": "",
        "kind": "service",
        "domain": "salvachillo.dapaas",
        "module": "dapaas_service"
      }
    }
  },
  "comment": "",
  "meta": {}
}
'
  ;;

'link') ;;

'deploy-all')
  $0 axebow-prep
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

'delete-domain')
  ${KAM_CMD} ctl unregister domain dapaas_serverdomain
  ;;

'delete-secret')
  ${KAM_CMD} ctl unregister secret dapaas_googleIdpClientId
  ${KAM_CMD} ctl unregister secret dapaas_googleIdpClientSecret
  ${KAM_CMD} ctl unregister secret dapaas_default_password
  ${KAM_CMD} ctl unregister secret dapaas_abwClusterAdmission
  ${KAM_CMD} ctl unregister secret dapaas_abwClusterCa
  ${KAM_CMD} ctl unregister secret dapaas_abwClusterCert
  ${KAM_CMD} ctl unregister secret dapaas_abwClusterKey
  ${KAM_CMD} ctl unregister secret dapaas_abwToken
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

# set +x
# set +e
