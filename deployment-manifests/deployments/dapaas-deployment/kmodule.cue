package kmodule

{
	domain: "salvachillo.dapaas"
	module: "dapaas_deployment"
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
		"salvachillo.dapaas/dapaas_service": {
			target: "salvachillo.dapaas/dapaas_service/@0.1.0"
			query:  "0.1.0"
		}
	}
	sums: {
		"kumori.systems/kumori/@1.1.7":               "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/dapaas_service/@0.1.0": "MPJY+khrBQv0P5fUMPD055EDcSduax2tSEXrwtnoKOQ="
	}
	spec: [
		1,
		0,
	]
}
