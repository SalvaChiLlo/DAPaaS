package kmodule

{
	domain: "salvachillo.dapaas"
	module: "workspace_deployment"
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
		"salvachillo.dapaas/user_workspace_service": {
			target: "salvachillo.dapaas/user_workspace_service/@0.1.0"
			query:  "0.1.0"
		}
	}
	sums: {
		"salvachillo.dapaas/minio_component/@0.0.2":             "FrvWxcB4KEQQwmNWUXGiZaYZqHKszB58SktdN9XCTvY="
		"salvachillo.dapaas/postgres_component/@0.0.2":          "16C1i3qsYRiC47oADk5MAf2J5PkpMsym2rg1PQTXlfc="
		"salvachillo.dapaas/grafana_component/@0.0.2":           "83IaYVz0RCgmgXBx3cQOgqTRPe82qADHIXi/Lwionao="
		"salvachillo.dapaas/airflow_service/@0.0.2":             "46neQU8UmyUgK7V9SBkPteWXI4sYg9Iq3uJJtWCmoMI="
		"salvachillo.dapaas/vscode_component/@0.0.2":            "rVbD9Ue/aKHeZ0oQYu2HvXVf4Ay4EdP1Fm786wOje3U="
		"salvachillo.dapaas/workspace_manager_component/@0.0.2": "uAgv3Wba8IhC/PZSKx6GAh4mYsKMSmpSD6whTpBIqoI="
		"salvachillo.dapaas/access_gateway_component/@0.0.2":    "4/ckojmqDDkvePrf+EVXpTXmx0sWnNzMyAmlnG75NCc="
		"kumori.systems/kumori/@1.1.7":                          "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/user_workspace_service/@0.1.0":      "1NRnZbf0b8ofvhy4z6QBjyDOTbQEqsXiVJ7D2wcqwYQ="
	}
	spec: [
		1,
		0,
	]
}
