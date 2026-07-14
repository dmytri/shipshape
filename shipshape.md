# Shipshape

Specifications are durable. Code is disposable. Agents are replaceable.

Shipshape is a context-isolated, spec-driven workflow for coding agents. Start with the durable specification in `skills/shipshape/SKILL.md` to learn the Articles of Agreement and workflow. Each role skill (`captain`, `qm`, `crew`, `boatswain`, `shipwright`) documents its own contract and duties. The skills are canonical; when this map and a skill disagree, the skill wins.

**Discovery:**
- Components: `skills/`, `agents/`, `hooks/`, `commands/`, `rules/`; manifest metadata in `.plugin/plugin.json`
- Onboarding: see `AGENTS.md`
- Workflow: see `skills/shipshape/SKILL.md`
- Role tasks: see `skills/<role>/SKILL.md`
- Conformance rules: see `rules/`
- Plugin commands: see `commands/`

**Structure:**
- Durable: `.feature` specs, `assets/**`, `CAPTAIN.md`, `watchbill.json`, `RIGGING.md`
- Disposable: verification support, step definitions, production code
- Trace: `@planks(...)` annotations on seams link code to spec
- Tags: `@captain` (skeleton), `@shipwright` (condemned), `@contract` (product's mechanical shape), `@conformance` (project's own method), `@exceptional-double` (justified test double), `@logic`/`@sandbox` (tiers)

**Entry:**
- `RIGGING.md` absent: `/shipwright` fits out
- Working tree dirty: Boatswain cleans
- Otherwise: `/captain`
