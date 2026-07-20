export function deepMergeConfig(
  config: any,
  overrideConfig: any,
  path: string = "",
): any {
  for (const k of Object.keys(overrideConfig)) {
    const oldConfig = config[k];
    const newConfig = overrideConfig[k];
    const configPath = path + (path ? "." : "") + k;

    if (
      oldConfig &&
      newConfig &&
      typeof oldConfig === "object" &&
      typeof newConfig === "object"
    ) {
      if (Object.keys(newConfig).length === 0) {
        delete config[k];
      }
      deepMergeConfig(oldConfig, newConfig, configPath);
    } else {
      config[k] = newConfig;
    }
  }
}
