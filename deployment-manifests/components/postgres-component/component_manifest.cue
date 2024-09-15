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
				postgres: {port: 5432}
			}
			client: {}
			duplex: {}
		}

		config: {
			parameter: {
				defaultUser:   *"admin" | string
				dbNames:       *["postgres"] | [...string]
				imageRegistry: *"docker.io" | string
			}
			resource: {
				defaultPassword:     k.#Secret
				imageRegistrySecret: k.#Secret

				postgres_vol: k.#Volume
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
					tag: "salvachll/postgres:20240831"
				}

				cmd: ["-c", "max_connections=5000"]

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/var/lib/postgresql": volume: "postgres_vol"

						"/docker-entrypoint-initdb.d/initdb.sh": {
							data: value: """
#!/bin/bash
set -e

# Split the POSTGRES_DBS variable into an array
IFS=',' read -r -a db_array <<< "$POSTGRES_DBS"

# Create each database in the array
for db in "${db_array[@]}"; do
    echo "Creating database: $db"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
        CREATE DATABASE $db;
EOSQL
done
"""
							mode: 0o777
						}
					}

					env: {
						POSTGRES_USER: value:      description.config.parameter.defaultUser
						POSTGRES_PASSWORD: secret: "defaultPassword"
						POSTGRES_DBS: value:       strings.Join(description.config.parameter.dbNames, ",")
					}
				}

				size: {
					memory: {size: 2000, unit: "M"}
					mincpu: 1000
					cpu: {size: 4000, unit: "m"}
				}
			}
		}
	}
}
