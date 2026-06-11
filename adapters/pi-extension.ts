/**
 * Shipshape Roles Extension for Pi
 *
 * Optional project-local Pi extension that registers /captain, /qm, /crew,
 * and /clearrole commands for the Shipshape three-role workflow.
 *
 * Installation:
 *   1. Copy this file to <project>/.pi/extensions/shipshape-roles.ts
 *   2. Ensure the project has Shipshape command prompts available at one of:
 *        - commands/captain.md, commands/qm.md, commands/crew.md
 *        - .claude/commands/captain.md, .claude/commands/qm.md, .claude/commands/crew.md
 *   3. Optional: keep agents/crew-mate.md available for the /crew command.
 *   4. Run /reload in Pi after adding or changing the extension.
 *
 * Important workflow boundary:
 *   Quartermaster must not inherit Captain/human discovery context. This
 *   extension refuses /qm if /captain was used earlier in the same Pi session.
 *   Start a fresh Pi session before invoking /qm after Captain.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type RoleName = "captain" | "qm" | "crew";

interface RoleState {
  name: RoleName;
  instructions: string;
  injected: boolean;
}

let roleState: RoleState | null = null;
let captainUsedInThisSession = false;

function firstExistingPath(paths: string[]): string | null {
  for (const candidate of paths) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

function projectPaths(cwd: string) {
  return {
    agentsPath: path.join(cwd, "AGENTS.md"),
    handoverPath: path.join(cwd, "HANDOVER.md"),
    commandPaths: (role: RoleName) => [
      path.join(cwd, "commands", `${role}.md`),
      path.join(cwd, ".claude", "commands", `${role}.md`),
      path.join(cwd, ".agents", "commands", `${role}.md`),
    ],
    crewAgentPaths: [
      path.join(cwd, "agents", "crew-mate.md"),
      path.join(cwd, ".claude", "agents", "crew-mate.md"),
      path.join(cwd, ".agents", "crew-mate.md"),
    ],
  };
}

function readMarkdownBody(filePath: string): string | null {
  try {
    const raw = fs.readFileSync(filePath, "utf8");
    return raw.replace(/^---\n[\s\S]*?\n---\n*/, "").trim();
  } catch {
    return null;
  }
}

function buildRoleInstructions(
  role: RoleName,
  args: string,
  cwd: string,
): { name: RoleName; instructions: string } | null {
  const paths = projectPaths(cwd);
  const commandPath = firstExistingPath(paths.commandPaths(role));
  if (!commandPath) return null;

  let instructions = readMarkdownBody(commandPath);
  if (!instructions) return null;

  if (role === "crew") {
    const crewAgentPath = firstExistingPath(paths.crewAgentPaths);
    const crewAgent = crewAgentPath ? readMarkdownBody(crewAgentPath) : null;
    if (crewAgent) {
      instructions += `\n\n## Crew Mate Agent Definition\n\n${crewAgent}`;
    }
  }

  if (fs.existsSync(paths.agentsPath)) {
    instructions +=
      "\n\n## Project Instructions\n\n" +
      "Read AGENTS.md before starting work. It is the authoritative project workflow and configuration file for Shipshape.\n";
  }

  if (role === "qm") {
    instructions +=
      "\n\n## Session Boundary\n\n" +
      "You must be running in a fresh session that does not include Captain/human discovery chat. " +
      "If this is not true, stop and ask the user to start a new Pi session before invoking /qm.\n";

    if (fs.existsSync(paths.handoverPath)) {
      instructions += "\n\n## Handover\n\n" + fs.readFileSync(paths.handoverPath, "utf8");
    }
  }

  const resolvedArgs = args.trim();
  instructions = instructions.replace(/\$ARGUMENTS/g, resolvedArgs);

  return { name: role, instructions };
}

export default function shipshapeRolesExtension(pi: ExtensionAPI) {
  pi.registerCommand("captain", {
    description: "Start a Shipshape Captain session for human-facing discovery and spec work",
    handler: async (args, ctx) => {
      const role = buildRoleInstructions("captain", args, ctx.cwd);
      if (!role) {
        ctx.ui.notify(
          "Captain prompt not found. Expected commands/captain.md or .claude/commands/captain.md.",
          "error",
        );
        return;
      }

      captainUsedInThisSession = true;
      roleState = { ...role, injected: false };
      ctx.ui.setStatus("shipshape-role", "🧭 Captain");
      ctx.ui.notify(
        "🧭 Captain activated. Capture decisions in specs/instructions, not chat.",
        "info",
      );

      const focus = args.trim()
        ? `Captain session started. Focus: ${args.trim()}`
        : "Captain session started. Read AGENTS.md and relevant specs, then begin discovery.";
      pi.sendUserMessage(focus);
    },
  });

  pi.registerCommand("qm", {
    description: "Start a Shipshape Quartermaster session in a fresh context",
    handler: async (args, ctx) => {
      if (captainUsedInThisSession) {
        ctx.ui.notify(
          "Do not start Quartermaster in a session that has used Captain. Start a fresh Pi session, then run /qm.",
          "error",
        );
        return;
      }

      const role = buildRoleInstructions("qm", args, ctx.cwd);
      if (!role) {
        ctx.ui.notify(
          "Quartermaster prompt not found. Expected commands/qm.md or .claude/commands/qm.md.",
          "error",
        );
        return;
      }

      roleState = { ...role, injected: false };
      ctx.ui.setStatus("shipshape-role", "⚙️ Quartermaster");
      ctx.ui.notify(
        "⚙️ Quartermaster activated. Derive work from verification status and committed artifacts only.",
        "info",
      );

      const focus = args.trim()
        ? `Quartermaster session started. Narrow focus: ${args.trim()}`
        : "Quartermaster session started. Read AGENTS.md and HANDOVER.md, then derive the worklist from verification status.";
      pi.sendUserMessage(focus);
    },
  });

  pi.registerCommand("crew", {
    description: "Start a Shipshape Crew Mate for one failing verification target",
    getArgumentCompletions: (_prefix) => null,
    handler: async (args, ctx) => {
      if (!args.trim()) {
        ctx.ui.notify("Usage: /crew <failing test, scenario, or verification target>", "error");
        return;
      }

      const role = buildRoleInstructions("crew", args, ctx.cwd);
      if (!role) {
        ctx.ui.notify(
          "Crew prompt not found. Expected commands/crew.md or .claude/commands/crew.md.",
          "error",
        );
        return;
      }

      roleState = { ...role, injected: false };
      ctx.ui.setStatus("shipshape-role", "🔧 Crew Mate");
      ctx.ui.notify(
        `🔧 Crew Mate activated. Target: ${args.trim()}`,
        "info",
      );

      pi.sendUserMessage(
        `Crew Mate session started. Target: ${args.trim()}\n\nRead committed specs and tests for behavior. Implement only the minimal production change needed.`,
      );
    },
  });

  pi.registerCommand("clearrole", {
    description: "Exit the current Shipshape role",
    handler: async (_args, ctx) => {
      const previousRole = roleState?.name;
      roleState = null;
      ctx.ui.setStatus("shipshape-role", undefined);
      ctx.ui.notify(
        previousRole ? `Cleared ${previousRole} role.` : "No Shipshape role was active.",
        "info",
      );
    },
  });

  pi.on("before_agent_start", async (event) => {
    if (!roleState || roleState.injected) return;

    roleState.injected = true;

    return {
      systemPrompt:
        `# Active Shipshape Role: ${roleState.name.toUpperCase()}\n\n` +
        `You are operating in the \"${roleState.name}\" role from the Shipshape workflow.\n\n` +
        `Role instructions:\n\n${roleState.instructions}\n\n---\n\n` +
        event.systemPrompt,
    };
  });

  pi.on("session_shutdown", async () => {
    roleState = null;
    captainUsedInThisSession = false;
  });
}
