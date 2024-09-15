package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				vscode: port: 8443
			}
			client: {
				workspace_manager: _
				postgres:          _
				s3:                _
				minio:             _
				airflow:           _
				grafana:           _
				fsync:             _
			}
			duplex: {}
		}

		config: {
			parameter: {
				imageRegistry: *"docker.io" | string
			}
			resource: {
				imageRegistrySecret: k.#Secret
				vscode_vol:          k.#Volume
				fsync_vol:           k.#Volume
				publicKey:           k.#Secret
				privateKey:          k.#Secret
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
					tag: "salvachll/vscode:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/config": volume:                  "vscode_vol"
						"/config/workspace/shared": volume: "fsync_vol"
					}

					env: {
						PUID: value:              "0"
						PGID: value:              "0"
						TZ: value:                "Europe/Madrid"
						DEFAULT_WORKSPACE: value: "/config/workspace"
					}
				}

				size: {
					memory: {size: 1, unit: "G"}
					cpu: {size: 1000, unit: "m"}
					mincpu: 500
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
