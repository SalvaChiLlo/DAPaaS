package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				s3: port:      9000
				console: port: 9001
			}
			client: {}
			duplex: {}
		}

		config: {
			parameter: {
				defaultUser:   *"admin" | string
				imageRegistry: *"docker.io" | string
				toolPath:      *"" | string
				toolUrl:       *"" | string
				toolWebPath:   *"" | string
				toolWebUrl:    *"" | string
			}
			resource: {
				defaultPassword:     k.#Secret
				imageRegistrySecret: k.#Secret

				minio_vol: k.#Volume
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
					tag: "salvachll/minio:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/bitnami/minio/data": volume: "minio_vol"
					}

					env: {
						MINIO_ROOT_USER: value:            description.config.parameter.defaultUser
						MINIO_ROOT_PASSWORD: secret:       "defaultPassword"
						MINIO_BROWSER_REDIRECT_URL: value: description.config.parameter.toolWebUrl
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
