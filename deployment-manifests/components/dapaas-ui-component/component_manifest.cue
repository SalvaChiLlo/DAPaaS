package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				ui: port: 80
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
					tag: "salvachll/dapaas-ui:20240915-r2"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {}

					env: {}
				}

				size: {
					memory: {size: 512, unit: "M"}
					mincpu: 100
					cpu: {size: 200, unit: "m"}
				}
			}
		}
	}
}
