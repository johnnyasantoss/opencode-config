import type { Plugin } from "@opencode-ai/plugin";

const readCommands = ["cat", "grep", "sed", "awk", "head", "tail"];

export const EnvProtection: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "read" && output.args.filePath.includes(".env")) {
        throw new Error("Do not read .env files");
      }

      // avoid reading with bash
      if (
        input.tool === "bash" &&
        typeof output.args.command === "string" &&
        output.args.command.includes(".env") &&
        readCommands.some((cmd) => output.args.command.includes(cmd))
      ) {
        throw new Error(
          "Do not execute commands that access .env files. Defer to user.",
        );
      }

      // avoid writing .envs
      if (input.tool === "write" && output.args.filePath.includes(".env")) {
        throw new Error("Do not write .env files. Defer to user.");
      }

      // avoid overwriting .envs
      if (
        input.tool === "bash" &&
        typeof output.args.command === "string" &&
        />[\s\\]*.env/.test(output.args.command)
      ) {
        throw new Error("Do not overwrite .env files. Defer to user.");
      }
    },
  };
};
