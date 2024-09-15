package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: ""

	description: {

		srv: {
			server: {
				api: port: 9080
			}
			client: {
				grafana:           _
				airflow:           _
				vscode:            _
				workspace_manager: _
				minio:             _
				s3:                _
			}
			duplex: {}
		}

		let params = config.parameter
		config: {
			parameter: {
				baseUrl:       *"https://dapaas.vera.kumori.cloud" | string
				imageRegistry: *"docker.io" | string

				grafanaToolUrl:   string
				grafanaToolPath:  string
				airflowToolUrl:   string
				airflowToolPath:  string
				vscodeToolUrl:    string
				vscodeToolPath:   string
				minioToolUrl:     string
				minioToolPath:    string
				minioWebToolUrl:  string
				minioWebToolPath: string

				allowedUsers: string

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
						"/usr/local/apisix/conf/config.yaml": {
							data: value: params.config_yaml
							format:         "yaml"
							rebootOnUpdate: true
							mode:           0o666
						}

						"/usr/local/apisix/conf/apisix.yaml": {
							rebootOnUpdate: false
							data: value: """
routes:
- uri: /\(description.config.parameter.vscodeToolPath)/*
  enable_websocket: true
  plugin_config_id: 1
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.vscode:80: 1
  plugins:
    proxy-rewrite:
      headers:
        x-forwarded-port: 443
      regex_uri: ["^/\(description.config.parameter.vscodeToolPath)(/?)(.*)", "/$2"]
      
- uri: /\(description.config.parameter.grafanaToolPath)/*
  enable_websocket: true
  plugin_config_id: 1
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.grafana:80: 1
  plugins:
    proxy-rewrite:
      headers:
        x-forwarded-port: 443
      regex_uri: ["^/\(description.config.parameter.grafanaToolPath)(/?)(.*)", "/$2"]
        
- uri: /\(description.config.parameter.airflowToolPath)/*
  enable_websocket: true
  plugin_config_id: 1
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.airflow:80: 1
  plugins:
    proxy-rewrite:
      headers:
        x-forwarded-port: 443
  #  proxy-rewrite:
  #      regex_uri: ["^/\(description.config.parameter.airflowToolPath)(/?)(.*)", "/$2"]

- uri: /\(description.config.parameter.minioToolPath)/*
  enable_websocket: true
  plugin_config_id: 1
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.s3:80: 1
  plugins:
    proxy-rewrite:
      headers:
        x-forwarded-port: 443
      regex_uri: ["^/\(description.config.parameter.minioToolPath)(/?)(.*)", "/$2"]

- uri: /\(description.config.parameter.minioWebToolPath)/*
  enable_websocket: true
  plugin_config_id: 1
  timeout:
    connect: 999999
    send: 999999
    read: 999999
  upstream:
    nodes:
      0.minio:80: 1
  plugins:
    proxy-rewrite:
      headers:
        x-forwarded-port: 443
      regex_uri: ["^/\(description.config.parameter.minioWebToolPath)(/?)(.*)", "/$2"]

plugins:
  - name: serverless-post-function
  - name: proxy-rewrite

plugin_configs:
- id: 1
  desc: "Only allow access to __ENV.ALLOWED_USERS"
  plugins:
    serverless-post-function:
      functions:
      - |-
        return function(conf, ctx)
            local core = require("apisix.core")
            local jwt = require("resty.jwt")
            local cjson = require("cjson")
            -- Helper function to respond with unauthorized status
            local function unauthorized()
                ngx.status = ngx.HTTP_UNAUTHORIZED
                ngx.header.content_type = "application/json; charset=utf-8"
                ngx.say(cjson.encode({ message = "Unauthorized" }))
                ngx.exit(ngx.HTTP_UNAUTHORIZED)
            end
            -- Get the allowed users from the environment variable
            local allowed_users = "\(description.config.parameter.allowedUsers)"
            if not allowed_users then
                core.log.error("ALLOWED_USERS environment variable is not set")
                unauthorized()
                return
            end
            -- Split allowed_users into a table
            local allowed_users_table = {}
            for user in allowed_users:gmatch("[^,]+") do
                table.insert(allowed_users_table, user)
            end
            -- Extract the Authorization header
            local auth_header = core.request.header(ctx, "Authorization")
            if not auth_header or not auth_header:find("Bearer ") then
                core.log.error("Missing or invalid Authorization header")
                unauthorized()
                return
            end
            local token = auth_header:sub(8) -- Extract token after "Bearer "
            -- Decode the JWT
            local decoded_token = jwt:load_jwt(token)
            if not decoded_token.valid then
                core.log.error("Invalid JWT token")
                unauthorized()
                return
            end
            local payload = decoded_token.payload
            -- Extract federated claims
            local federated_claims = payload.federated_claims
            if not federated_claims or not federated_claims.connector_id or not federated_claims.user_id then
                core.log.error("Federated claims missing in token")
                unauthorized()
                return
            end
            local user_identifier = federated_claims.connector_id .. "_" .. federated_claims.user_id
            -- Check if the user identifier is in the allowed users
            local is_allowed = false
            for _, allowed_user in ipairs(allowed_users_table) do
                if allowed_user == user_identifier then
                    is_allowed = true
                    break
                end
            end
            if not is_allowed then
                core.log.error("User not authorized: " .. user_identifier)
                unauthorized()
                return
            end
        end
      phase: rewrite
#END
"""
							format: "text"
							mode:   0o666
						}
					}

					env: {
						ECHO_INCLUDE_ENV_VARS: value: "1"
						ALLOWED_USERS: value:         description.config.parameter.allowedUsers
					}
				}

				size: {
					memory: {size: 2000, unit: "M"}
					mincpu: 500
					cpu: {size: 1000, unit: "m"}
				}
			}
		}
	}
}
