package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				dex: port: 5556
			}
			client: {}
			duplex: {}
		}

		let params = config.parameter
		config: {
			parameter: {
				imageRegistry:  *"docker.io" | string
				baseUrl:        *"https://dapaas.vera.kumori.cloud" | string
				dexSubpath:     *"idp" | string
				dexDisplayName: *"DEX Idp" | string
			}
			resource: {
				imageRegistrySecret:   k.#Secret
				googleIdpClientId:     k.#Secret
				googleIdpClientSecret: k.#Secret
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
					tag: "salvachll/dex:20240831"
				}

				cmd: ["dex", "serve", "/config/config.yaml"]

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/config/config.yaml": {
							data: value: {
								issuer: "\(params.baseUrl)/\(params.dexSubpath)/"
								frontend: issuer:           params.dexDisplayName
								storage: type:              "memory"
								web: http:                  "0.0.0.0:5556"
								oauth2: skipApprovalScreen: true

								connectors: [
									{
										type: "google"
										id:   "google"
										name: "Google"
										config: {
											clientID:     "$GOOGLE_CLIENT_ID"
											clientSecret: "$GOOGLE_CLIENT_SECRET"
											redirectURI:  "\(issuer)callback"
										}
									},
								]

								staticClients: [
									{
										id: "superclientid"
										redirectURIs: [
											"\(params.baseUrl)/callback",
											"\(params.baseUrl)/api/callback",
										]
										name:   "localhost"
										secret: "bar"
									},
								]

								expiry: {
									idTokens: "48h"
									refreshTokens: {
										validIfNotUsedFor: "2160h"
									}
								}

							}
							format:         "yaml"
							rebootOnUpdate: true
						}
					}

					env: {
						GOOGLE_CLIENT_ID: secret:     "googleIdpClientId"
						GOOGLE_CLIENT_SECRET: secret: "googleIdpClientSecret"
					}
				}

				size: {
					memory: {size: 256, unit: "M"}
					mincpu: 100
					cpu: {size: 200, unit: "m"}
				}
			}
		}
	}
}
