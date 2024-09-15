package service

import (
	k "kumori.systems/kumori:kumori"
	minio_comp "salvachillo.dapaas/minio_component:component"
)

#Artifact: {
	ref: name: ""
	description: {

		config: {
			parameter: {
				common: {
					defaultUser:   *"admin" | string
					imageRegistry: *"docker.io" | string
				}

				minio: {

				}
			}
			resource: {
				defaultPassword:     k.#Secret
				imageRegistrySecret: k.#Secret

				minio_vol: k.#Volume
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
					}
				}
			}
		}

		srv: {
			server: {
        s3: _
      }
		}

		connect: {
			c_minio_s3: {
				from: self: "s3"
				to: minio: s3: _
			}
		}
	}
}
