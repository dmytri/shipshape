---
description: "Audit Shipshape installation integrity: completeness, freshness, and coherence across channels and scopes. Read-only."
disable-model-invocation: false
---

# Shipshape doctor

This command audits the Shipshape installation itself. It applies the current-design rule to the harness: no stale copies, no drift, no shadowed doctrine. It adds no doctrine.

Evidence rule: run each check and show the command output. Report what the output shows, never an unverified assurance. Change nothing without approval.

Portability rule: the checks are the contract; the example commands are examples. Use the host platform's equivalents for paths, hashing, and shell syntax, and the current runtime's own layout for skill and plugin directories.

1. **Inventory.** Locate every installed copy of the Shipshape skills, across generic and runtime-specific layouts:
   - generic agent directories, project and global, such as `.agents/skills/` and `~/.agents/skills/`;
   - runtime-specific skill directories, project and global, in each runtime's own skill layout;
   - the runtime's plugin root, where the plugin channel installs `shipshape` with skills, agents, and hooks.
   Record location, channel, and scope for each copy. The channels are skills and plugin. The scopes are project and global. Symlinked copies resolve to their targets; record both the link and the target.
2. **Completeness.** A skills-channel copy carries all six skills: `shipshape`, `captain`, `qm`, `crew`, `boatswain`, `shipwright`, and the shipwright skill's `templates.md`. A plugin-channel copy also carries `agents/`, `hooks/`, `commands/`, and `rules/`, and every `hooks/scripts/*.sh` is executable. Flag partial copies and lost execute bits.
3. **Freshness.** Compare each installed `SKILL.md` against upstream `main` by content hash, for example:

   ```bash
   curl -s https://raw.githubusercontent.com/dmytri/shipshape/main/skills/captain/SKILL.md | sha256sum
   sha256sum <installed path>/captain/SKILL.md
   ```

   Use the host platform's hash tool: `sha256sum` on Linux, `shasum -a 256` on macOS, `Get-FileHash` on Windows. A direct file diff against the fetched upstream copy is an equal substitute. The skills channel carries no version numbers; content comparison is the check. For a plugin-channel copy, also compare the `version` in `.plugin/plugin.json` against upstream. Flag every stale copy.
4. **Coherence.** Flag duplicate installs across scopes and channels. Name which copy the runtime resolves first and which copies it shadows. Multiple copies at different vintages mean an agent can invoke stale doctrine with full confidence; recommend collapsing to one channel.
5. **Report and remedies.** Present a table: location, channel, scope, completeness, freshness. Recommend the fix for each finding: `npx skills update` for stale skills-channel copies, `npx plugins add dmytri/shipshape` to refresh the plugin channel, and removal of redundant channels. Apply a remedy only when the user approves it.
