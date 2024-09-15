package service

import (
	k "kumori.systems/kumori:kumori"
	minio_comp "salvachillo.dapaas/minio_component:component"
	postgres_comp "salvachillo.dapaas/postgres_component:component"
	grafana_comp "salvachillo.dapaas/grafana_component:component"
	airflow_comp "salvachillo.dapaas/airflow_service:service"
	vscode_comp "salvachillo.dapaas/vscode_component:component"
	workspace_manager_comp "salvachillo.dapaas/workspace_manager_component:component"
	access_gateway_comp "salvachillo.dapaas/access_gateway_component:component"
	fsync_comp "salvachillo.dapaas/fsync_component:component"
)

#Artifact: {
	ref: name: ""
	description: {

		config: {
			parameter: {
				common: {
					imageRegistry:      *"docker.io" | string
					defaultUser:        *"admin" | string
					dbNames:            *["dapaas"] | [...string]
					baseUrl:            *"https://dapaas.vera.kumori.cloud" | string
					workspaceUrlPrefix: *"workspace" | string
					jwksUrl:            *"\(baseUrl)/auth/certs" | string

					tenant:      string
					creatorUser: string
				}

				minio: {
					toolPath: "\(config.parameter.common.workspaceUrlPrefix)/minio"
					toolUrl:  "\(config.parameter.common.baseUrl)/\(toolPath)"

					toolWebPath: "\(config.parameter.common.workspaceUrlPrefix)/minio-console"
					toolWebUrl:  "\(config.parameter.common.baseUrl)/\(toolWebPath)"
				}

				postgres: {

				}

				grafana: {
					toolPath: "\(config.parameter.common.workspaceUrlPrefix)/grafana"
					toolUrl:  "\(config.parameter.common.baseUrl)/\(toolPath)"
				}

				airflow: {
					toolPath: "\(config.parameter.common.workspaceUrlPrefix)/airflow"
					toolUrl:  "\(config.parameter.common.baseUrl)/\(toolPath)"
				}

				vscode: {
					toolPath: "\(config.parameter.common.workspaceUrlPrefix)/vscode"
					toolUrl:  "\(config.parameter.common.baseUrl)/\(toolPath)"
				}

				workspace_manager: {
					toolPath: "\(config.parameter.common.workspaceUrlPrefix)/manager"
					toolUrl:  "\(config.parameter.common.baseUrl)/\(toolPath)"

					workspaceId: description.config.parameter.common.workspaceUrlPrefix
				}

				access_gateway: {
					grafanaToolUrl:   description.config.parameter.grafana.toolUrl
					grafanaToolPath:  description.config.parameter.grafana.toolPath
					airflowToolUrl:   description.config.parameter.airflow.toolUrl
					airflowToolPath:  description.config.parameter.airflow.toolPath
					vscodeToolUrl:    description.config.parameter.vscode.toolUrl
					vscodeToolPath:   description.config.parameter.vscode.toolPath
					minioToolUrl:     description.config.parameter.minio.toolUrl
					minioToolPath:    description.config.parameter.minio.toolPath
					minioWebToolUrl:  description.config.parameter.minio.toolWebUrl
					minioWebToolPath: description.config.parameter.minio.toolWebPath
					allowedUsers:     string
				}

				fsync: {

				}
			}
			resource: {
				defaultPassword:     k.#Secret
				imageRegistrySecret: k.#Secret
				publicKey:           k.#Secret
				privateKey:          k.#Secret

				minio_vol:    k.#Volume
				postgres_vol: k.#Volume
				grafana_vol:  k.#Volume
				vscode_vol:   k.#Volume
				fsync_vol:    k.#Volume
			}
		}

		let registryCredentials = {
			parameter: {
				imageRegistry: description.config.parameter.common.imageRegistry
			}
			resource: {
				imageRegistrySecret: description.config.resource.imageRegistrySecret
			}
		}

		role: {

			minio: {
				artifact: minio_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.minio
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						minio_vol:       description.config.resource.minio_vol
						fsync_vol:       description.config.resource.fsync_vol
					}
				}
			}

			postgres: {
				artifact: postgres_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.postgres
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						postgres_vol:    description.config.resource.postgres_vol
						fsync_vol:       description.config.resource.fsync_vol
					}
				}
			}

			grafana: {
				artifact: grafana_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.grafana
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						grafana_vol:     description.config.resource.grafana_vol
						fsync_vol:       description.config.resource.fsync_vol
					}
				}
			}

			airflow: {
				artifact: airflow_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.airflow
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						fsync_vol:       description.config.resource.fsync_vol
						publicKey:       description.config.resource.publicKey
						privateKey:      description.config.resource.privateKey
					}
					scale: detail: {
						airflow_webserver: hsize: 1
						airflow_scheduler: hsize: 1
						airflow_triggerer: hsize: 0
						airflow_worker: hsize:    1
						redis: hsize:             1
					}
				}
			}

			vscode: {
				artifact: vscode_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.vscode
					resource: {
						vscode_vol: description.config.resource.vscode_vol
						fsync_vol:  description.config.resource.fsync_vol
						publicKey:  description.config.resource.publicKey
						privateKey: description.config.resource.privateKey
					}
				}
			}

			workspace_manager: {
				artifact: workspace_manager_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.workspace_manager
					resource: {
						fsync_vol:  description.config.resource.fsync_vol
						publicKey:  description.config.resource.publicKey
						privateKey: description.config.resource.privateKey
					}
				}
			}

			access_gateway: {
				artifact: access_gateway_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.access_gateway
					resource: {}
				}
			}

			fsync: {
				artifact: fsync_comp.#Artifact
				config:   registryCredentials
				config: {
					parameter: description.config.parameter.common
					parameter: description.config.parameter.fsync
					resource: {
						defaultPassword: description.config.resource.defaultPassword
						fsync_vol:       description.config.resource.fsync_vol
						publicKey:       description.config.resource.publicKey
						privateKey:      description.config.resource.privateKey
					}
				}
			}
		}

		srv: {
			server: {
				workspace_manager: _
				access_gateway:    _
			}
			client: {
				platform: _
			}
		}

		connect: {
			c_minio__s3: {
				as: "lb"
				from: access_gateway:    "s3"
				from: airflow:           "s3"
				from: grafana:           "s3"
				from: vscode:            "s3"
				from: workspace_manager: "s3"
				to: minio: s3: _
			}

			c_minio__console: {
				as: "lb"
				from: access_gateway:    "minio"
				from: airflow:           "minio"
				from: grafana:           "minio"
				from: vscode:            "minio"
				from: workspace_manager: "minio"
				to: minio: console: _
			}

			c_postgres__postgres: {
				as: "lb"
				from: airflow:           "postgres"
				from: grafana:           "postgres"
				from: vscode:            "postgres"
				from: workspace_manager: "postgres"
				to: postgres: postgres: _
			}

			c_grafana__web: {
				as: "lb"
				from: access_gateway:    "grafana"
				from: airflow:           "grafana"
				from: vscode:            "grafana"
				from: workspace_manager: "grafana"
				to: grafana: web: _
			}

			c_airflow__airflow: {
				as: "lb"
				from: access_gateway:    "airflow"
				from: grafana:           "airflow"
				from: vscode:            "airflow"
				from: workspace_manager: "airflow"
				to: airflow: airflow: _
			}

			c_vscode__vscode: {
				as: "lb"
				from: access_gateway:    "vscode"
				from: airflow:           "vscode"
				from: grafana:           "vscode"
				from: workspace_manager: "vscode"
				to: vscode: vscode: _
			}

			c_workspace_manager__api: {
				as: "lb"
				from: self:    "workspace_manager"
				from: airflow: "workspace_manager"
				from: grafana: "workspace_manager"
				from: vscode:  "workspace_manager"
				to: workspace_manager: api: _
			}

			c_access_gateway__api: {
				as: "lb"
				from: self: "access_gateway"
				to: access_gateway: api: _
			}

			c_fsync__ssh: {
				as: "lb"
				from: vscode:            "fsync"
				from: airflow:           "fsync"
				from: workspace_manager: "fsync"
				to: fsync: ssh: _
			}
		}
	}
}
