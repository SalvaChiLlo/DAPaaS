package component

import k "kumori.systems/kumori:kumori"

#Artifact: {

	ref: name: "components/airflow"

	description: {

		srv: {
			server: {
				api: port:    8080
				worker: port: 8793
			}
			client: {
				fsync:             _
				s3:                _
				postgres:          _
				redis:             _
				workspace_manager: _
				logs:              _
			}
			duplex: {}
		}

		let _cfgp = config.parameter

		config: {
			parameter: {
				imageRegistry: *"docker.io" | string
				defaultUser:   *"admin" | string

				command:          string
				airflow_base_url: *"https://dapaas.vera.kumori.cloud/workspace/workspace_1/airflow" | string

				AIRFLOW_WORKER_TASK_CONCURRENCY:         *32 | number
				AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG:  *2048 | number
				AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG: *64 | number
				AIRFLOW__CORE__PARALLELISM:              *2048 | number

				AIRFLOW__API__AUTH_BACKENDS: "airflow.api.auth.backend.session"

				AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: *"true" | string
				AIRFLOW__CORE__DAGS_FOLDER:                 *"/home/airflow/volume/airflow/sources/dags" | string
				AIRFLOW__CORE__EXECUTOR:                    *"CeleryExecutor" | string
				AIRFLOW__CORE__LOAD_EXAMPLES:               *"true" | string
				AIRFLOW__CORE__PLUGINS_FOLDER:              *"/opt/airflow/plugins" | string
				AIRFLOW__CORE__SQL_ALCHEMY_CONN:            *"postgresql+psycopg2://admin:adminadmin@0.postgres:80/airflow" | string

				AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: *"postgresql+psycopg2://admin:adminadmin@0.postgres:80/airflow" | string
				AIRFLOW__LOGGING__BASE_LOG_FOLDER:   *"/home/airflow/volume/airflow/sources/logs" | string
				AIRFLOW__LOGGING__FAB_LOGGING_LEVEL: *"INFO" | string
				AIRFLOW__LOGGING__LOGGING_LEVEL:     *"INFO" | string

				AIRFLOW_DB_UPGRADE:          *"true" | string
				AIRFLOW_WWW_USER_CREATE:     *"true" | string
				PIP_ADDITIONAL_REQUIREMENTS: *"" | string
				DUMB_INIT_SETSID:            *"0" | string

				sizes: {
					webserver: k.#ContainerSize
					scheduler: k.#ContainerSize
					triggerer: k.#ContainerSize
					worker:    k.#ContainerSize
				}
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
		let _command = description.config.parameter.command

		code: {

			main: {
				name: "main"

				image: {
					hub: {
						name:   config.parameter.imageRegistry
						secret: "imageRegistrySecret"
					}
					tag: "salvachll/airflow:20240831"
				}

				user: {
					userid:  0
					groupid: 0
				}

				mapping: {

					filesystem: {
						"/home/airflow/volume": {
							volume: "fsync_vol"
						}
					}

					env: {
						AIRFLOW_UID: value: "0"

						AIRFLOW__SCHEDULER__ENABLE_HEALTH_CHECK: value: "true"
						AIRFLOW__CELERY__RESULT_BACKEND: value:         "db+postgresql://admin:adminadmin@0.postgres:80/airflow"
						AIRFLOW__CELERY__BROKER_URL: value:             "redis://:@0.redis:80/0"
						AIRFLOW_WORKER_TASK_CONCURRENCY: value:         "\(_cfgp.AIRFLOW_WORKER_TASK_CONCURRENCY)"
						AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG: value:  "\(_cfgp.AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG)"
						AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG: value: "\(_cfgp.AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG)"
						AIRFLOW__CORE__PARALLELISM: value:              "\(_cfgp.AIRFLOW__CORE__PARALLELISM)"
						AIRFLOW__CORE__MP_START_METHOD: value:          "fork"

						AIRFLOW__WEBSERVER__BASE_URL: value:         description.config.parameter.airflow_base_url
						AIRFLOW__WEBSERVER__EXPOSE_CONFIG: value:    "true"
						AIRFLOW__WEBSERVER__FILTER_BY_OWNER: value:  "true"
						AIRFLOW__WEBSERVER__X_FRAME_ENABLED: value:  "true"
						AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX: value: "true"

						AIRFLOW__API__AUTH_BACKENDS: value: _cfgp.AIRFLOW__API__AUTH_BACKENDS

						AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: value: _cfgp.AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION
						AIRFLOW__CORE__DAGS_FOLDER: value:                 _cfgp.AIRFLOW__CORE__DAGS_FOLDER
						AIRFLOW__CORE__EXECUTOR: value:                    _cfgp.AIRFLOW__CORE__EXECUTOR
						AIRFLOW__CORE__LOAD_EXAMPLES: value:               _cfgp.AIRFLOW__CORE__LOAD_EXAMPLES
						AIRFLOW__CORE__PLUGINS_FOLDER: value:              _cfgp.AIRFLOW__CORE__PLUGINS_FOLDER
						AIRFLOW__CORE__SQL_ALCHEMY_CONN: value:            _cfgp.AIRFLOW__CORE__SQL_ALCHEMY_CONN

						AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: value:         _cfgp.AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
						AIRFLOW__DATABASE__SQL_ALCHEMY_MAX_OVERFLOW: value: "-1"
						AIRFLOW__DATABASE__SQL_ALCHEMY_POOL_SIZE: value:    "0"
						AIRFLOW__LOGGING__BASE_LOG_FOLDER: value:           _cfgp.AIRFLOW__LOGGING__BASE_LOG_FOLDER
						AIRFLOW__LOGGING__FAB_LOGGING_LEVEL: value:         _cfgp.AIRFLOW__LOGGING__FAB_LOGGING_LEVEL
						AIRFLOW__LOGGING__LOGGING_LEVEL: value:             _cfgp.AIRFLOW__LOGGING__LOGGING_LEVEL

						AIRFLOW_DB_UPGRADE: value:          _cfgp.AIRFLOW_DB_UPGRADE
						AIRFLOW_WWW_USER_CREATE: value:     _cfgp.AIRFLOW_WWW_USER_CREATE
						AIRFLOW_WWW_USER_USERNAME: value:   _cfgp.defaultUser
						AIRFLOW_WWW_USER_PASSWORD: secret:  "defaultPassword"
						PIP_ADDITIONAL_REQUIREMENTS: value: _cfgp.PIP_ADDITIONAL_REQUIREMENTS
						DUMB_INIT_SETSID: value:            _cfgp.DUMB_INIT_SETSID
						C_FORCE_ROOT: value:                "True"

						AIRFLOW_COMMAND: value: _command // webserver, kafka_worker, schedulermod.local
					}
				}

				if (_command == "webserver") {
					size: _cfgp.sizes.webserver
				}

				if (_command == "scheduler") {
					size: _cfgp.sizes.scheduler
				}

				if (_command == "triggerer") {
					size: _cfgp.sizes.triggerer
				}

				if (_command == "celery worker") {
					size: {
						memory: {size: 6000, unit: "M"}
						cpu: {size: 1500, unit: "m"}
						mincpu: 500
					}
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
