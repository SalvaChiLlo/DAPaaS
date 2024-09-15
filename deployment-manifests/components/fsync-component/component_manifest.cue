package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				ssh: port: 22
			}
			client: {}
			duplex: {}
		}

		config: {
			parameter: {
				imageRegistry: *"docker.io" | string
			}
			resource: {
				imageRegistrySecret: k.#Secret
				defaultPassword:     k.#Secret
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
					tag: "salvachll/fsync:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"\(mapping.env.VOL_DIR.value)": volume: "fsync_vol"
					}

					env: {
						VOL_DIR: value: "/volume"

						PUBLIC_KEY: secret:  "publicKey"
						PRIVATE_KEY: secret: "privateKey"

						PUID: value: "0"
						PGID: value: "0"

						TZ: value: "Europe/Madrid"

						SUDO_ACCESS: value: "true"
						// PASSWORD_ACCESS: value: "true"
						USER_PASSWORD: secret: "defaultPassword"
						USER_NAME: value:      "root"
					}
				}

				size: {
					memory: {size: 1, unit: "G"}
					cpu: {size: 1000, unit: "m"}
					mincpu: 500
				}
			}
		}
	}
}
