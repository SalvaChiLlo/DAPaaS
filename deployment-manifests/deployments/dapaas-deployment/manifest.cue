package deployment

import ds "salvachillo.dapaas/dapaas_service:service"

#Deployment: {
	name:     "dapaas"
	artifact: ds.#Artifact
	config: {
		parameter: {
			common: {
				defaultUser:   "admin"
				imageRegistry: "docker.io"
				dbNames: ["dapaas"]
				baseUrl: "https://dapaas.vera.kumori.cloud"
				cmcUrl:  "https://cmc-forge.vera.kumori.cloud/api/nightly"
			}

			core_srv: {
				dex: {
					dexSubpath:     "idp"
					dexDisplayName: "DAPaaS Login"
				}

				api_gateway: {

				}

				dapaas_api: {

				}

				dapaas_ui: {

				}

				postgres: {

				}
			}

			dataset_store_srv: {
				minio: {

				}
			}
		}
		resource: {
			defaultPassword: secret:       "dapaas_default_password"
			imageRegistrySecret: secret:   "cluster.core/docker_hub_demo"
			googleIdpClientId: secret:     "dapaas_googleIdpClientId"
			googleIdpClientSecret: secret: "dapaas_googleIdpClientSecret"
			abwClusterAdmission: secret:   "dapaas_abwClusterAdmission"
			abwToken: secret:              "dapaas_abwToken"
			abwClusterCert: secret:        "dapaas_abwClusterCert"
			abwClusterKey: secret:         "dapaas_abwClusterKey"
			abwClusterCa: secret:          "dapaas_abwClusterCa"

			servercert: certificate: "cluster.core/wildcard-vera-kumori-cloud"

			serverdomain: domain: "dapaas_serverdomain"

			minio_vol: volume: {size: 5, unit: "G"}
			postgres_vol: volume: {size: 5, unit: "G"}
		}
		scale: detail: {}
		// resilience: 1
	}
}
