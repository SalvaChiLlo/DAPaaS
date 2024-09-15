package deployment

import (
	uws "salvachillo.dapaas/user_workspace_service:service"
)

#Deployment: {
	name:     "dapaas-platform"
	artifact: uws.#Artifact
	config: {
		parameter: {
			common: {
				defaultUser:   "admin"
				imageRegistry: "docker.io"
				dbNames: ["dapaas", "airflow"]
				baseUrl:            "https://dapaas.vera.kumori.cloud"
				workspaceUrlPrefix: "workspace/workspace1"

				jwksUrl: "\(baseUrl)/idp/keys" // TODO

				tenant:      ""
				creatorUser: ""
			}

			minio: {

			}

			postgres: {

			}

			grafana: {

			}

			airflow: {

			}

			vscode: {

			}

			workspace_manager: {

			}

			access_gateway: {
				allowedUsers: "google_111161353767835030764"
			}

			fsync: {

			}
		}
		resource: {
			defaultPassword: secret:     "dapaas_default_password"
			imageRegistrySecret: secret: "cluster.core/docker_hub_demo"
			publicKey: secret:           "dapaas_publicKey"
			privateKey: secret:          "dapaas_privateKey"

			minio_vol: volume: {size: 1, unit: "G"}
			postgres_vol: volume: {size: 1, unit: "G"}
			grafana_vol: volume: {size: 1, unit: "G"}
			vscode_vol: volume: {size: 1, unit: "G"}
			fsync_vol: volume: {size: 1, unit: "G"}
		}
		scale: detail: {
			minio: hsize:             0
			postgres: hsize:          1
			grafana: hsize:           0
			airflow: hsize:           1
			vscode: hsize:            1
			workspace_manager: hsize: 0
			access_gateway: hsize:    1
			fsync: hsize:             1
		}
	}
  meta: {
    workspaceId: config.parameter.common.workspaceUrlPrefix
  }
}
