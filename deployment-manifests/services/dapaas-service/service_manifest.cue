package service

import (
	k "kumori.systems/kumori:kumori"
	core_srv "salvachillo.dapaas/core_service:service"
	dataset_store_srv "salvachillo.dapaas/dataset_store_service:service"
)

#Artifact: {
	ref: name: ""
	description: {

		config: {
			parameter: {
				common: {
					defaultUser:   *"admin" | string
					imageRegistry: *"docker.io" | string
					dbNames:       *["dapaas"] | [...string]
					baseUrl:       *"https://dapaas.vera.kumori.cloud" | string
					cmcUrl:        *"https://cmc-forge.vera.kumori.cloud/api/nightly" | string
				}

				core: {
					dex: {
						dexSubpath:     *"idp" | string
						dexDisplayName: *"DEX Idp" | string
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

				dataset_store: {
					minio: {

					}
				}
			}
			resource: {
				defaultPassword:       k.#Secret
				imageRegistrySecret:   k.#Secret
				googleIdpClientId:     k.#Secret
				googleIdpClientSecret: k.#Secret
				abwClusterAdmission:   k.#Secret
				abwToken:              k.#Secret
				abwClusterCert:        k.#Secret
				abwClusterKey:         k.#Secret
				abwClusterCa:          k.#Secret

				servercert: k.#Certificate

				serverdomain: k.#Domain

				minio_vol:    k.#Volume
				postgres_vol: k.#Volume
			}
		}

		let registryCredentials = {
			parameter: {
				imageRegistry: description.config.parameter.common.imageRegistry
			}
			resource: {
				imageRegistrySecret: description.config.resource.imageRegistrySecret
			}
		}

		role: {
			core: {
				artifact: core_srv.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.core
					resource: {
						defaultPassword:       description.config.resource.defaultPassword
						googleIdpClientId:     description.config.resource.googleIdpClientId
						googleIdpClientSecret: description.config.resource.googleIdpClientSecret
						abwClusterAdmission:   description.config.resource.abwClusterAdmission
						abwToken:              description.config.resource.abwToken
						abwClusterCert:        description.config.resource.abwClusterCert
						abwClusterKey:         description.config.resource.abwClusterKey
						abwClusterCa:          description.config.resource.abwClusterCa

						servercert: description.config.resource.servercert

						serverdomain: description.config.resource.serverdomain

						postgres_vol: description.config.resource.postgres_vol
					}
					scale: detail: {
						dex: hsize:         1
						api_gateway: hsize: 1
						dapaas_api: hsize:  1
						dapaas_ui: hsize:   1
						postgres: hsize:    1
					}
				}
			}

			dataset_store: {
				artifact: dataset_store_srv.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.dataset_store
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						minio_vol:       description.config.resource.minio_vol
					}
					scale: detail: {
						minio: hsize: 1
					}
				}
			}

		}

		srv: {
			client: {
				workspace: {}
				workspace_manager: {}
			}
		}

		connect: {
			c_dataset_store_s3: {
				as: "lb"
				from: core: "s3"
				to: dataset_store: "s3": _
			}

			c_self__workspace: {
				as: "lb"
				from: core: "workspace"
				to: self: workspace: _
			}
			c_self__workspace_manager: {
				as: "lb"
				from: core: "workspace_manager"
				to: self: workspace_manager: _
			}

		}
	}
}
