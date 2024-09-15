const fs = require("fs");
const path = require("path");
const chokidar = require("chokidar");
const yaml = require("yaml");

// File paths
const kumori_config_path =
  process.env.KUMORI_CONFIG_PATH ?? "./example_config.json"; // Path to your JSON file
const apisix_config_template_path =
  process.env.APISIX_CONFIG_TEMPLATE_PATH ?? "./example_apisix_config.yaml"; // Path to your YAML file
const apisix_config_path = process.env.APISIX_CONFIG_PATH ?? "./apisix.yaml"; // Path to your YAML file

// Function to update YAML based on JSON content
function updateYamlFromJson() {
  // Read and parse the JSON file
  const jsonData = JSON.parse(fs.readFileSync(kumori_config_path, "utf8"));
  const workspaces = jsonData.channels.workspace;

  // Read and parse the YAML template file
  const yamlData = fs.readFileSync(apisix_config_template_path, "utf8");
  let routes = yaml.parse(yamlData);

  // Find the host for the route with uri: /api/*
  const apiRoute = routes.routes.find((route) => route.uri === "/api/*");
  if (!apiRoute) {
    console.error("No route found with uri: /api/*");
    return;
  }
  const host = apiRoute.host;

  // Ensure the 'routes' key exists in YAML
  if (!routes.routes) {
    routes.routes = [];
  }

  // Iterate over workspaces to find the workspaceId and create a route entry
  Object.keys(workspaces).forEach((workspaceVSet) => {
    const workspaceEntries = workspaces[workspaceVSet];
    workspaceEntries.forEach((entry) => {
      const workspaceId = entry.user.workspaceId;
      if (workspaceId) {
        // Check if route for this workspace already exists
        const existingRoute = routes.routes.find(
          (route) => route.uri === `/${workspaceId}/*`
        );
        if (!existingRoute) {
          // Create a new route entry
          const newRoute = {
            uri: `/${workspaceId}/*`,
            host: host,
            enable_websocket: true,
            plugin_config_id: 1,
            timeout: {
              connect: 999999,
              send: 999999,
              read: 999999,
            },
            upstream: {
              nodes: {},
            },
          };
          newRoute.upstream.nodes[`${workspaceVSet}.workspace:80`] = 1;
          routes.routes.push(newRoute);
        }
      }
    });
  });

  // Convert the updated routes object back to YAML
  const newYamlData = `
${yaml.stringify(routes)}  
#END
`;

  // Write the updated YAML to the target file
  fs.writeFileSync(apisix_config_path, newYamlData, "utf8");
  console.log(`YAML file updated and written to ${apisix_config_path}`);
}

// Watch the JSON file for changes
chokidar.watch(kumori_config_path).on("change", () => {
  console.log("JSON file changed. Updating YAML...");
  updateYamlFromJson();
});

// Initial run to update YAML
updateYamlFromJson();
