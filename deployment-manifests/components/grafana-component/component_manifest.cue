package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				web: port: 3000
			}
			client: {
				postgres:          _
				s3:                _
				minio:             _
				vscode:            _
				airflow:           _
				workspace_manager: _
			}
			duplex: {}
		}

		config: {
			parameter: {
				imageRegistry: *"docker.io" | string
				defaultUser:   *"admin" | string

				toolUrl: string
				jwksUrl: string
			}
			resource: {
				imageRegistrySecret: k.#Secret
				defaultPassword:     k.#Secret

				grafana_vol: k.#Volume
			}
		}

		size: {
			bandwidth: {size: 1000, unit: "M"}
		}

		probe: {
			main: {
				liveness: {
					protocol: http: {
						port: srv.server.web.port
						path: "/api/health"
					}
					startupGraceWindow: {unit: "ms", duration: 4 * 60 * 1000, probe: true}
					frequency: "medium"
					timeout:   10 * 1000 // msec
				}
				readiness: {
					protocol: http: {
						port: srv.server.web.port
						path: "/api/health"
					}
					frequency: "medium"
					timeout:   10 * 1000 // msec
				}
			}
		}

		#init: []

		code: {

			main: {
				name: "main"

				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "salvachll/grafana:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/var/lib/grafana": volume: "grafana_vol"
					}

					env: {
						GF_SERVER_ROOT_URL: value: "\(description.config.parameter.toolUrl)/"

						GF_SECURITY_ADMIN_USER: value:      description.config.parameter.defaultUser
						GF_SECURITY_ADMIN_PASSWORD: secret: "defaultPassword"
						GF_SECURITY_ALLOW_EMBEDDING: value: "true"

						GF_AUTH_JWT_ENABLED: value:        "true"
						GF_AUTH_JWT_HEADER_NAME: value:    "authorization"
						GF_AUTH_JWT_USERNAME_CLAIM: value: "preferred_username"
						GF_AUTH_JWT_EMAIL_CLAIM: value:    "email"
						GF_AUTH_JWT_AUTO_SIGN_UP: value:   "true"
						GF_AUTH_JWT_JWK_SET_URL: value:    description.config.parameter.jwksUrl

						GF_USERS_ALLOW_SIGN_UP: value:        "true"
						GF_USERS_AUTO_ASSIGN_ORG: value:      "true"
						GF_USERS_AUTO_ASSIGN_ORG_ROLE: value: "Admin"
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
