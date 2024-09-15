package kmodule

{
	domain: "salvachillo.dapaas"
	module: "dataset_store_service"
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
	}
	sums: {
		"kumori.systems/kumori/@1.1.7":              "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/minio_component/@0.1.0": "Xp/dgDdNQwjD/EoHpd1JAAZ55Fj3+lQKl3bq6bI82gI="
	}
	spec: [
		1,
		0,
	]
}
