package kmodule

{
	domain: "salvachillo.dapaas"
	module: "dapaas_service"
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
		"salvachillo.dapaas/core_service": {
			target: "salvachillo.dapaas/core_service/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/dataset_store_service": {
			target: "salvachillo.dapaas/dataset_store_service/@0.1.0"
			query:  "0.1.0"
		}
	}
	sums: {
		"kumori.systems/kumori/@1.1.7":                    "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/core_service/@0.1.0":          "5MqRxCf2e0b/ARWCT86TncuRykVXuZeRhhjVrN6fuUY="
		"salvachillo.dapaas/dataset_store_service/@0.1.0": "Ckw50YRpxsLKmPWXYOubxFwCYPhKij1OnHt/87wI3U0="
	}
	spec: [
		1,
		0,
	]
}
