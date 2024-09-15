package service

import (
	k "kumori.systems/kumori:kumori"
	i "kumori.systems/builtins/inbound:service"
	api_gateway_comp "salvachillo.dapaas/api_gateway_component:component"
	dapaas_api_comp "salvachillo.dapaas/dapaas_api_component:component"
	dapaas_ui_comp "salvachillo.dapaas/dapaas_ui_component:component"
	postgres_comp "salvachillo.dapaas/postgres_component:component"
	dex_comp "salvachillo.dapaas/dex_component:component"
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

				api_gateway: {

				}

				dapaas_api: {
					database_type: "postgres"
					database_name: config.parameter.common.dbNames[0]
				}

				dapaas_ui: {

				}

				postgres: {

				}

				dex: {
					dexSubpath:     *"idp" | string
					dexDisplayName: *"DEX Idp" | string
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
			dex: {
				artifact: dex_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.dex
					resource: {
						googleIdpClientId:     description.config.resource.googleIdpClientId
						googleIdpClientSecret: description.config.resource.googleIdpClientSecret
					}
				}
			}

			api_gateway: {
				artifact: api_gateway_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.api_gateway
					resource: {}
				}
			}

			dapaas_api: {
				artifact: dapaas_api_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.dapaas_api
					resource: {
						abwClusterAdmission: description.config.resource.abwClusterAdmission
						abwToken:            description.config.resource.abwToken
						abwClusterCert:      description.config.resource.abwClusterCert
						abwClusterKey:       description.config.resource.abwClusterKey
						abwClusterCa:        description.config.resource.abwClusterCa
						defaultPassword:     description.config.resource.defaultPassword
					}
				}
			}

			dapaas_ui: {
				artifact: dapaas_ui_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.dapaas_ui
					resource: {

					}
				}
			}

			postgres: {
				artifact: postgres_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.postgres
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						postgres_vol:    description.config.resource.postgres_vol
					}
				}
			}

			dapaas_inbound: {
				artifact: i.#Artifact
				config: {
					parameter: {
						type:      "https"
						websocket: true
					}
					resource: {
						servercert:   description.config.resource.servercert
						serverdomain: description.config.resource.serverdomain
					}
				}
			}
		}

		srv: {
			client: {
				s3:                _
				workspace:         _
				workspace_manager: _
			}
		}

		connect: {
			c_self_s3: {
				from: dapaas_api: "dataset_store"
				to: self: s3: _
			}

			c_self_workspace: {
				from: api_gateway: "workspace"
				to: self: workspace: _
			}

			c_self_workspace_manager: {
				from: dapaas_api: "workspace_manager"
				to: self: workspace_manager: _
			}

			c_dex_dex: {
				as: "lb"
				from: api_gateway: "idp"
				to: dex: dex: _
			}
			c_api_gateway_api: {
				as: "lb"
				from: dapaas_inbound: "inbound"
				to: api_gateway: api: _
			}
			c_dapaas_api_api: {
				as: "lb"
				from: api_gateway: "platform_api"
				to: dapaas_api: api: _
			}
			c_dapaas_ui_ui: {
				as: "lb"
				from: api_gateway: "wui"
				to: dapaas_ui: ui: _
			}
			c_postgres_postgres: {
				as: "lb"
				from: dapaas_api: "platform_db"
				to: postgres: postgres: _
			}
		}
	}
}
