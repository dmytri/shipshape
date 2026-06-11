# Zed Adapter

Zed supports reusable skills through `SKILL.md` files.

## As a Zed Skill

Use this repository directly as a skill source, or copy `SKILL.md` and supporting files into a Zed skill directory.

Typical global location:

```text
~/.agents/skills/shipshape/SKILL.md
```

The skill frontmatter must keep:

```yaml
name: shipshape
```

## Project Adoption

For a project using Shipshape:

1. Copy `templates/AGENTS.md` to the project root.
2. Fill in the project-specific placeholders.
3. Optionally copy `templates/HANDOVER.md`.
4. Ask the Zed agent to use the Shipshape skill and run the Captain role first.
5. Before running Quartermaster, clear the session or start a fresh agent session so QM does not inherit Captain chat context.

## Subagents

If Zed subagent dispatch is available, the Quartermaster can dispatch Crew Mate tasks. If not, use the Quartermaster fallback rule or start separate Crew sessions manually.
