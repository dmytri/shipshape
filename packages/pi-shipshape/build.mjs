import { cpSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(packageDir, "../..");
const outDir = join(repoRoot, "dist/pi-shipshape");

const entries = [
  "README.md",
  "LICENSE",
  "shipshape",
  "captain",
  "qm",
  "crew",
  "agents",
  "commands",
  "adapters",
  "templates",
  "docs",
  "skills.sh.json",
];

rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

for (const entry of entries) {
  cpSync(join(repoRoot, entry), join(outDir, entry), { recursive: true });
}

cpSync(join(packageDir, "package.json"), join(outDir, "package.json"));

console.log(`Built ${outDir}`);
