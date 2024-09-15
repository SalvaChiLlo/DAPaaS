package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				api: port: 8080
				// api: port: 3400
			}
			client: {
				platform:   _
				data_store: _
				postgres:   _
				airflow:    _
				minio:      _
				s3:         _
				grafana:    _
				vscode:     _
				fsync:      _
			}
			duplex: {}
		}

		config: {
			parameter: {
				imageRegistry: *"docker.io" | string

				tenant:      string
				creatorUser: string

				workspaceId: string
			}
			resource: {
				imageRegistrySecret: k.#Secret
        publicKey:           k.#Secret
				privateKey:          k.#Secret

				fsync_vol: k.#Volume
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

			main: {
				name: "main"

				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "mendhak/http-https-echo"
					// tag: "salvachll/workspace-manager:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {}

					env: {
						WORKSPACE_OWNER: value: description.config.parameter.tenant
						WORKSPACE_USER: value:  description.config.parameter.creatorUser
						WORKSPACE_ID: value:    description.config.parameter.workspaceId
					}
				}

				size: {
					memory: {size: 512, unit: "M"}
					mincpu: 100
					cpu: {size: 1000, unit: "m"}
				}
			}
			fsync_client: {
				name: "fsync_client"

				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "salvachll/fsync-client:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				entrypoint: ["/bin/setup_sync.sh"]

				mapping: {
					filesystem: {

						"/volume": {
							volume: "fsync_vol"
						}
					}

					env: {
						FSYNC_SSH_CONNECTION: value: "root@0.fsync:80"
						PUBLIC_KEY: secret:          "publicKey"
						PRIVATE_KEY: secret:         "privateKey"
					}
				}

				size: {
					memory: {size: 512, unit: "M"}
					cpu: {size: 1000, unit: "m"}
					mincpu: 500
				}
			}
		}
	}
}
