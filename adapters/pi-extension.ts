/**
 * Shipshape Roles Extension for Pi
 *
 * Pi extension that registers /captain, /qm, /crew, /bosun, and /clearrole commands
 * for the Shipshape role-based workflow.
 *
 * Resolution order for role skill prompts:
 *   1. Project-local skill overrides in .agents/skills/<role>/SKILL.md or <role>/SKILL.md
 *   2. Packaged Shipshape <role>/SKILL.md bundled with the installed npm package
 *
 * After installing or updating the package, run /reload in Pi if needed.
 *
 * Important workflow boundary:
 *   Quartermaster must not inherit Captain/human discovery context. This
 *   extension refuses /qm if /captain was used earlier in the same Pi session.
 *   Start a fresh Pi session before invoking /qm after Captain.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type RoleName = "captain" | "qm" | "crew" | "bosun";

interface RoleState {
    name: RoleName;
    instructions: string;
    injected: boolean;
}

let roleState: RoleState | null = null;
let captainUsedInThisSession = false;

const packageRoot = path.resolve(
    path.dirname(fileURLToPath(import.meta.url)),
    "..",
);

function firstExistingPath(paths: string[]): string | null {
    for (const candidate of paths) {
        if (fs.existsSync(candidate)) return candidate;
    }
    return null;
}

function projectPaths(cwd: string) {
    return {
        agentsPath: path.join(cwd, "AGENTS.md"),
        skillPaths: (role: RoleName) => [
            path.join(cwd, ".agents", "skills", role, "SKILL.md"),
            path.join(cwd, role, "SKILL.md"),
            path.join(packageRoot, role, "SKILL.md"),
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
    const skillPath = firstExistingPath(paths.skillPaths(role));
    if (!skillPath) return null;

    let instructions = readMarkdownBody(skillPath);
    if (!instructions) return null;

    if (role !== "qm" && fs.existsSync(paths.agentsPath)) {
        instructions +=
            "\n\n## Project Instructions\n\n" +
            "Read AGENTS.md before starting work. It is the authoritative project workflow and configuration file for Shipshape.\n";
    }

    if (role === "qm") {
        instructions +=
            "\n\n## Session Boundary\n\n" +
            "You must be running in a fresh session that does not include Captain/human discovery chat. " +
            "If this is not true, stop and ask the user to start a new Pi session before invoking /qm.\n";
    }

    return { name: role, instructions };
}

export default function shipshapeRolesExtension(pi: ExtensionAPI) {
    pi.registerCommand("captain", {
        description:
            "Start a Shipshape Captain session for human-facing discovery and spec work",
        handler: async (args, ctx) => {
            const role = buildRoleInstructions("captain", args, ctx.cwd);
            if (!role) {
                ctx.ui.notify(
                    "Captain skill prompt not found. Expected a project-local override or the packaged Shipshape captain/SKILL.md.",
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
        description:
            "Start a Shipshape Quartermaster session in a fresh context",
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
                    "Quartermaster skill prompt not found. Expected a project-local override or the packaged Shipshape qm/SKILL.md.",
                    "error",
                );
                return;
            }

            roleState = { ...role, injected: false };
            ctx.ui.setStatus("shipshape-role", "⚙️ Quartermaster");
            ctx.ui.notify(
                "⚙️ Quartermaster activated. Derive work from verification status and durable repo artifacts only.",
                "info",
            );

            const focus = args.trim()
                ? `Quartermaster session started. Narrow focus: ${args.trim()}`
                : "Quartermaster session started. Derive the worklist from verification status.";
            pi.sendUserMessage(focus);
        },
    });

    pi.registerCommand("crew", {
        description:
            "Start a Shipshape Crew Mate for one failing verification target",
        getArgumentCompletions: (_prefix) => null,
        handler: async (args, ctx) => {
            if (!args.trim()) {
                ctx.ui.notify(
                    "Usage: /crew <failing test, scenario, or verification target>",
                    "error",
                );
                return;
            }

            const role = buildRoleInstructions("crew", args, ctx.cwd);
            if (!role) {
                ctx.ui.notify(
                    "Crew skill prompt not found. Expected a project-local override or the packaged Shipshape crew/SKILL.md.",
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
                `Crew Mate session started. Target: ${args.trim()}\n\nRead durable specs and source-controlled tests for behavior. Implement only the minimal production change needed.`,
            );
        },
    });

    pi.registerCommand("bosun", {
        description:
            "Start Shipshape Bosun for repo hygiene and local commit custody",
        getArgumentCompletions: (_prefix) => null,
        handler: async (args, ctx) => {
            const role = buildRoleInstructions("bosun", args, ctx.cwd);
            if (!role) {
                ctx.ui.notify(
                    "Bosun skill prompt not found. Expected a project-local override or the packaged Shipshape bosun/SKILL.md.",
                    "error",
                );
                return;
            }

            roleState = { ...role, injected: false };
            ctx.ui.setStatus("shipshape-role", "⚓ Bosun");
            ctx.ui.notify(
                "⚓ Bosun activated. Clean the deck, commit locally, then load Captain for outbound decisions.",
                "info",
            );

            const focus = args.trim()
                ? `Bosun session started. Completed work: ${args.trim()}`
                : "Bosun session started. Inspect git status/diff, run hygiene checks, verify, commit locally, then load Captain for outbound decisions.";
            pi.sendUserMessage(focus);
        },
    });

    pi.registerCommand("clearrole", {
        description: "Exit the current Shipshape role",
        handler: async (_args, ctx) => {
            const previousRole = roleState?.name;
            roleState = null;
            ctx.ui.setStatus("shipshape-role", undefined);
            if (!previousRole) {
                ctx.ui.notify("No Shipshape role was active.", "info");
            } else if (captainUsedInThisSession) {
                ctx.ui.notify(
                    `Cleared ${previousRole} role. This session still contains Captain chat context — start a fresh Pi session before /qm.`,
                    "info",
                );
            } else {
                ctx.ui.notify(`Cleared ${previousRole} role.`, "info");
            }
        },
    });

    pi.on("before_agent_start", async (event) => {
        if (!roleState || roleState.injected) return;

        roleState.injected = true;

        return {
            systemPrompt:
                `# Active Shipshape Role: ${roleState.name.toUpperCase()}\n\n` +
                `You are operating in the "${roleState.name}" role from the Shipshape workflow.\n\n` +
                `Role instructions:\n\n${roleState.instructions}\n\n---\n\n` +
                event.systemPrompt,
        };
    });

    pi.on("session_shutdown", async () => {
        roleState = null;
        captainUsedInThisSession = false;
    });
}
