package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				api: port: 3000
			}
			client: {
				workspace_manager: _
				platform_db:       _
				dataset_store:     _
			}
			duplex: {}
		}

		config: {
			parameter: {
				imageRegistry:     *"docker.io" | string
				baseUrl:           *"https://dapaas.vera.kumori.cloud" | string
				cmcUrl:            *"https://cmc-forge.vera.kumori.cloud/api/nightly" | string
				defaultUser:       *"admin" | string
				database_type:     "postgres"
				database_name:     "dapaas"
				database_path:     ""
				database_host:     "0.platform_db"
				database_port:     "80"
				database_username: defaultUser
			}
			resource: {
				imageRegistrySecret: k.#Secret
				abwClusterAdmission: k.#Secret
				abwToken:            k.#Secret
				abwClusterCert:      k.#Secret
				abwClusterKey:       k.#Secret
				abwClusterCa:        k.#Secret
				defaultPassword:     k.#Secret
			}
		}

		size: {
			bandwidth: {size: 1000, unit: "M"}
		}

		// probe: main: {
		//  liveness: {
		//   protocol: http: {
		//    port: srv.server.restapi.port
		//    path: "/health"
		//   }
		//   startupGraceWindow: {
		//    unit:     "ms"
		//    duration: 20000
		//    probe:    true
		//   }
		//   frequency: "medium"
		//   timeout:   30000 // msec
		//  }
		//  readiness: {
		//   protocol: http: {
		//    port: srv.server.restapi.port
		//    path: "/health"
		//   }
		//   frequency: "medium"
		//   timeout:   30000 // msec
		//  }
		// }

		#init: []

		code: {

			api: {
				name: "api"

				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "salvachll/dapaas-api:20240915-r1"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {}

					env: {
						ABW_TOKEN: secret:             "abwToken"
						ABW_CLUSTER_ADMISSION: secret: "abwClusterAdmission"
						ABW_CLUSTER_CERT: secret:      "abwClusterCert"
						ABW_CLUSTER_KEY: secret:       "abwClusterKey"
						ABW_CLUSTER_CA: secret:        "abwClusterCa"

						CMC_URL: value:  description.config.parameter.cmcUrl
						BASE_URL: value: description.config.parameter.baseUrl

						DATABASE_TYPE: value:      description.config.parameter.database_type
						DATABASE_NAME: value:      description.config.parameter.database_name
						DATABASE_PATH: value:      description.config.parameter.database_path
						DATABASE_HOST: value:      description.config.parameter.database_host
						DATABASE_PORT: value:      description.config.parameter.database_port
						DATABASE_USERNAME: value:  description.config.parameter.database_username
						DATABASE_PASSWORD: secret: "defaultPassword"
					}
				}

				size: {
					memory: {size: 512, unit: "M"}
					mincpu: 100
					cpu: {size: 1000, unit: "m"}
				}
			}
		}
	}
}
