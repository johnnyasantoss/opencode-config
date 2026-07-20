/// <reference types="bun" />
import type { Plugin } from "@opencode-ai/plugin";
import { JSONC, sleep } from "bun";
import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { inspect } from "node:util";
import { deepMergeConfig } from "../utils/deepMerge";

const isDebug = !!process.env.DEBUG;

export const OverridePlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const log = (message: string, extra?: Record<string, unknown>) => {
    const error = Object.values(extra || {}).find(
      (item) => item && typeof item === "object" && "error" in item,
    );

    isDebug && console.debug(`[OVERRIDE] ${message}`, extra);

    client.app
      .log({
        body: {
          level: error ? "error" : "debug",
          service: "override-config",
          message: `[OVERRIDE]: ${message}`,
          extra,
        },
      })
      .catch((err) => {
        console.error("Failed to log to opencode", err);
      });
  };
  log("Initializing");

  const configDir = join(import.meta.dir, "..");
  const tryGetConfig = async (file: string) => {
    try {
      const path = join(configDir, file);

      log("Trying to read " + path);
      const config = (await readFile(path)).toString();
      log("Found config at " + path, { config });

      return JSONC.parse(config);
    } catch (error: any) {
      if (error?.code === "ENOENT") return;

      log("Failed to load config", { error: inspect(error) });
    }
  };

  let loadedConfig = false;
  const profile = process.env.OPENCODE_PROFILE || "override";

  return {
    config: async (config) => {
      const overrideConfig =
        (await tryGetConfig(`opencode.${profile}.jsonc`)) ||
        (await tryGetConfig(`opencode.${profile}.json`));

      if (!overrideConfig) return;

      log("Loaded config. Merging.", {
        overrideConfig: Object.keys(overrideConfig),
      });

      deepMergeConfig(config, overrideConfig);
      loadedConfig = true;
    },
    event: async ({ event }) => {
      if (loadedConfig && (event.type as string) === "catalog.updated") {
        await sleep(1000).then(() =>
          client.tui.showToast({
            body: {
              variant: "success",
              duration: 3000,
              title: "Profile Override Plugin",
              message: `Loaded profile configurations: "${profile}"`,
            },
          }),
        );
      }
    },
  };
};

export default OverridePlugin;
