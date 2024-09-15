package kmodule

{
	domain: "salvachillo.dapaas"
	module: "core_service"
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
		"salvachillo.dapaas/api_gateway_component": {
			target: "salvachillo.dapaas/api_gateway_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/dapaas_api_component": {
			target: "salvachillo.dapaas/dapaas_api_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/dapaas_ui_component": {
			target: "salvachillo.dapaas/dapaas_ui_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/postgres_component": {
			target: "salvachillo.dapaas/postgres_component/@0.1.0"
			query:  "0.1.0"
		}
		"salvachillo.dapaas/dex_component": {
			target: "salvachillo.dapaas/dex_component/@0.1.0"
			query:  "0.1.0"
		}
		"kumori.systems/builtins/inbound": {
			target: "kumori.systems/builtins/inbound/@1.3.0"
			query:  "1.3.0"
		}
	}
	sums: {
		"kumori.systems/kumori/@1.1.7":                    "kPdupjoBs/7ZLsDSsJCXEoY4Su+L3LCpbXMK4nBwbQY="
		"salvachillo.dapaas/api_gateway_component/@0.1.0": "34X3AunjWQf6534LzO6vE6s+ZIOM51/GhJKwy+vhrI8="
		"salvachillo.dapaas/dapaas_api_component/@0.1.0":  "sUORj/7bfOeSFZU39gtTEFeLkkbOit9iWZl4WByGKvM="
		"salvachillo.dapaas/dapaas_ui_component/@0.1.0":   "zKaenL6uLwMfvobaNsO/B+cVhxcuDicnPBPPygIlhss="
		"salvachillo.dapaas/postgres_component/@0.1.0":    "MmL0wofEeXSETEU2hk6MbLYEFumhWciZavTKhWHMmmc="
		"salvachillo.dapaas/dex_component/@0.1.0":         "acrcV/F73xeVbFIYOOWcIs7Qu56rZ3Jk62+FKjW0lDQ="
		"kumori.systems/builtins/inbound/@1.3.0":          "F3nipPPUCZ4YpsAh+Xnh9t8W1Tu98eX6SHRVM3BbRYs="
	}
	spec: [
		1,
		0,
	]
}
