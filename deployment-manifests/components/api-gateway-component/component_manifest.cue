package component

import (
	k "kumori.systems/kumori:kumori"
	"strings"
)

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				api: port: 9080
			}
			client: {
				workspace:    _
				platform_api: _
				idp:          _
				wui:          _
			}
			duplex: {}
		}

		let params = config.parameter
		config: {
			parameter: {
				baseUrl:       *"https://dapaas.vera.kumori.cloud" | string
				imageRegistry: *"docker.io" | string

				config_yaml: {
					apisix: {
						config_center: "yaml"
						enable_admin:  false
					}
					deployment: {
						role: "data_plane"
						role_data_plane: {
							config_provider: "yaml"
						}
					}
				}
			}
			resource: {
				imageRegistrySecret: k.#Secret

				gateway_config_vol: volume: {size: 512, unit: "M"}
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
					tag: "salvachll/apisix:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/usr/local/apisix/conf": volume: "gateway_config_vol"

						"/usr/local/apisix/conf/config.yaml": {
							data: value: params.config_yaml
							format:         "yaml"
							rebootOnUpdate: true
							mode:           0o666
						}
					}

					env: {}
				}

				size: {
					memory: {size: 2000, unit: "M"}
					cpu: {size: 1000, unit: "m"}
					mincpu: 500
				}
			}
			gateway_configurator: {
				name: "gateway_configurator"
				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "salvachll/dapaas-api-gateway-configurator:20240915"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {
					filesystem: {
						"\(mapping.env.SHARED_DIR.value)": volume: "gateway_config_vol"

						"\(mapping.env.SHARED_DIR.value)/config.yaml": {
							data: value: params.config_yaml
							format:         "yaml"
							rebootOnUpdate: true
							mode:           0o666
						}

						"\(mapping.env.APISIX_CONFIG_TEMPLATE_PATH.value)": {
							rebootOnUpdate: false
							data: value: """
routes:
- uri: /idp/*
  hosts:
  - \(strings.TrimPrefix(params.baseUrl, "https://"))
  enable_websocket: true
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.idp:80: 1
- uri: /*
  host: \(strings.TrimPrefix(params.baseUrl, "https://"))
  enable_websocket: true
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  plugin_config_id: 1
  upstream:
    nodes:
      0.wui:80: 1
- uri: /api/*
  host: \(strings.TrimPrefix(params.baseUrl, "https://"))
  enable_websocket: true
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  plugin_config_id: 1
  upstream:
    nodes:
      0.platform_api:80: 1

plugins:
  - name: openid-connect
  - name: serverless-post-function

plugin_configs:
- id: 1
  desc: "Enable authentication plugin - DAPAAS"
  plugins:
    openid-connect:
      access_token_in_authorization_header: true
      client_id: superclientid
      client_secret: bar
      discovery: \(params.baseUrl)/idp/.well-known/openid-configuration
      logout_path: /api/logout
      post_logout_redirect_uri: /
      redirect_uri: \(params.baseUrl)/api/callback
      scope: openid email profile offline_access groups federated:id
      session:
        secret: Mysecretisasecretthatfewpeopleactuallyknownanythingabout
      set_access_token_header: true
      set_id_token_header: true
      set_refresh_token_header: true
      # unauth_action: deny # This should be used with APIs
      use_jwks: true
#END
"""
							format: "text"
							mode:   0o666
						}
					}

					env: {
						SHARED_DIR: value:                  "/volume"
						KUMORI_CONFIG_PATH: value:          "/kumori/config.json"
						APISIX_CONFIG_TEMPLATE_PATH: value: "/tmp/apisix/apisix.yaml"
						APISIX_CONFIG_PATH: value:          "\(SHARED_DIR.value)/apisix.yaml"
					}
				}

				size: {
					memory: {size: 100, unit: "M"}
					cpu: {size: 100, unit: "m"}
					mincpu: 100
				}
			}
		}
	}
}
