package kmodule

{
	domain: "salvachillo.dapaas"
	module: "user_workspace_service"
	cue:    "0.4.2"
	version: [
		0,
		1,
		0,
	]
	dependencies: {
		"kumori.systems/kumori": {
			target: "kumori.systems/kumori/@1.1.7"
			query:  "1.1.7"
		}
		"salvachillo.dapaas/minio_component": {
			target: "salvachillo.dapaas/minio_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/postgres_component": {
			target: "salvachillo.dapaas/postgres_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/grafana_component": {
			target: "salvachillo.dapaas/grafana_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/airflow_service": {
			target: "salvachillo.dapaas/airflow_service/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/vscode_component": {
			target: "salvachillo.dapaas/vscode_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/workspace_manager_component": {
			target: "salvachillo.dapaas/workspace_manager_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/access_gateway_component": {
			target: "salvachillo.dapaas/access_gateway_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/fsync_component": {
			target: "salvachillo.dapaas/fsync_component/@0.1.0"
			query:  "0.1.0"
		}
	}
	sums: {
		"kumori.systems/kumori/@1.1.7":                          "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/minio_component/@0.1.0":             "Xp/dgDdNQwjD/EoHpd1JAAZ55Fj3+lQKl3bq6bI82gI="
		"salvachillo.dapaas/postgres_component/@0.1.0":          "MmL0wofEeXSETEU2hk6MbLYEFumhWciZavTKhWHMmmc="
		"salvachillo.dapaas/grafana_component/@0.1.0":           "aEzIwbcpYov9FMvKLwMoswgB6zX9ElOQ+ggBAEj25Fw="
		"salvachillo.dapaas/airflow_service/@0.1.0":             "lxO5GEh/jwi51kheSYw4XEF1i8oNdpfw4FL9WJR1Bjw="
		"salvachillo.dapaas/vscode_component/@0.1.0":            "vpL6kqahLvyZ4edYzZwcwW/zCwNfSzn2ix53Ux1bum8="
		"salvachillo.dapaas/workspace_manager_component/@0.1.0": "8ypq+i8Ts1iT+OXbAtN5+N6cCMUljd8a+b8qV4brHf8="
		"salvachillo.dapaas/access_gateway_component/@0.1.0":    "NU6MjqXbQTqk/GXRB5eGQXs7ugTXo+AOHmD1ukjSPSs="
		"salvachillo.dapaas/fsync_component/@0.1.0":             "osXcKYLjmoSKJV4bUvDAbw16NygIQFRUaBSAkRyAwYQ="
	}
	spec: [
		1,
		0,
	]
}
