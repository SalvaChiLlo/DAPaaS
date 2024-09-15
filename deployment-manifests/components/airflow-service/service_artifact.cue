package service

import (
	k "kumori.systems/kumori:kumori"
	airflow_comp "mod.local/components/airflow:component"
	redis_comp "mod.local/components/redis:component"
)

#Artifact: {
	ref: name: ""

	description: {
		srv: {
			server: {
				airflow: _
			}
			client: {
				postgres:          _
				s3:                _
				minio:             _
				grafana:           _
				vscode:            _
				workspace_manager: _
				fsync:             _
			}
			duplex: {}
		}

		config: {
			parameter: {
				defaultUser:   *"admin" | string
				imageRegistry: *"docker.io" | string

				toolUrl:          string
				airflow_base_url: toolUrl

				AIRFLOW_WORKER_TASK_CONCURRENCY:         *32 | number
				AIRFLOW__CORE__MAX_ACTIVE_RUNS_PER_DAG:  *2048 | number
				AIRFLOW__CORE__MAX_ACTIVE_TASKS_PER_DAG: *64 | number
				AIRFLOW__CORE__PARALLELISM:              *2048 | number
				AIRFLOW__CORE__LOAD_EXAMPLES:            *"true" | string
				AIRFLOW__LOGGING__FAB_LOGGING_LEVEL:     *"INFO" | string
				AIRFLOW__LOGGING__LOGGING_LEVEL:         *"INFO" | string

				let default_container_size = {
					memory: {size: 1000, unit: "M"}
					cpu: {size: 1500, unit: "m"}
					mincpu: 500
				}
				sizes: {
					webserver: k.#ContainerSize | *default_container_size
					scheduler: k.#ContainerSize | *default_container_size
					triggerer: k.#ContainerSize | *default_container_size
					worker:    k.#ContainerSize | *default_container_size
				}
			}
			resource: {
				defaultPassword:     k.#Secret
				imageRegistrySecret: k.#Secret
				publicKey:           k.#Secret
				privateKey:          k.#Secret

				fsync_vol: k.#Volume
			}
		}

		let _params = description.config.parameter

		let _resources = description.config.resource

		let _airflow_compr = {
			fsync_vol:           _resources.fsync_vol
			defaultPassword:     _resources.defaultPassword
			imageRegistrySecret: _resources.imageRegistrySecret
			publicKey:           _resources.publicKey
			privateKey:          _resources.privateKey
		}

		role: {
			airflow_webserver: {
				artifact: airflow_comp.#Artifact
				config: {
					resource: _airflow_compr
					parameter: command: "webserver"
					parameter: _params
				}
			}

			airflow_scheduler: {
				artifact: airflow_comp.#Artifact
				config: {
					resource: _airflow_compr
					parameter: command: "scheduler"
					parameter: _params
				}
			}

			airflow_triggerer: {
				artifact: airflow_comp.#Artifact
				config: {
					resource: _airflow_compr
					parameter: command: "triggerer"
					parameter: _params
				}
			}

			airflow_worker: {
				artifact: airflow_comp.#Artifact
				config: {
					resource: _airflow_compr
					parameter: command: "celery worker"
					parameter: _params
				}
				meta: {
					hpa: {
						enabled:     true
						minReplicas: 1
						maxReplicas: 4
						metrics: [{
							type: "Resource"
							resource: {
								name: "cpu"
								target: {
									type:               "Utilization"
									averageUtilization: 70
								}
							}
						}]
					}
				}

			}

			redis: {
				artifact: redis_comp.#Artifact
				config: {
					resource: {
						imageRegistrySecret: _resources.imageRegistrySecret
					}
				}
			}
		}

		connect: {
			c_self_postgres: {
				as: "lb"
				from: airflow_webserver: "postgres"
				from: airflow_scheduler: "postgres"
				from: airflow_triggerer: "postgres"
				from: airflow_worker:    "postgres"
				to: self: postgres: _
			}

			c_airflow_webserver__api: {
				as: "lb"
				from: self: "airflow"
				to: airflow_webserver: api: _
			}

			c_self_fsync: {
				as: "lb"
				from: airflow_webserver: "fsync"
				from: airflow_scheduler: "fsync"
				from: airflow_triggerer: "fsync"
				from: airflow_worker:    "fsync"
				to: self: fsync: _
			}

			c_self__workspace_manager: {
				as: "lb"
				from: airflow_webserver: "workspace_manager"
				from: airflow_scheduler: "workspace_manager"
				from: airflow_triggerer: "workspace_manager"
				from: airflow_worker:    "workspace_manager"
				to: self: workspace_manager: _
			}

			c_self_s3: {
				as: "lb"
				from: airflow_webserver: "s3"
				from: airflow_scheduler: "s3"
				from: airflow_triggerer: "s3"
				from: airflow_worker:    "s3"
				to: self: s3: _
			}

			c_redis_redis: {
				as: "lb"
				from: airflow_webserver: "redis"
				from: airflow_scheduler: "redis"
				from: airflow_triggerer: "redis"
				from: airflow_worker:    "redis"
				to: redis: redis: _
			}
		}
	}
}
