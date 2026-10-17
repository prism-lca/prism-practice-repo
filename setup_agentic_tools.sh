#!/usr/bin/env bash
# Set up Claude Code, Codex and opencode for this repo from .agents/, the one
# source of truth:
#
#   .agents/mcp.json        MCP servers   -> claude (local scope), .codex/config.toml, opencode.json
#   .agents/skills/<name>/  skills        -> symlinked into .claude/skills
#   .agents/agents/<name>.md agents       -> symlinked into .claude/agents, .opencode/agents
#
# Files it writes in the repo are gitignored; only .agents/ is committed.
# Outside the repo it adds this checkout's MCP servers to ~/.claude.json
# (local scope) and marks the checkout trusted in ~/.codex/config.toml.
# Safe to run any number of times: each run rebuilds the same result.
#
# Usage: ./setup_agentic_tools.sh [--install-clis]
#   --install-clis  npm-install any of the three CLIs that are missing, and
#                   install the Python, matplotlib and slide tools
#                   (the devcontainer passes this; local runs usually don't)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/.agents"

install_clis=false
for arg in "$@"; do
  case "$arg" in
    --install-clis) install_clis=true ;;
    -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '  %s\n' "$*"; }

# --- CLIs -------------------------------------------------------------------
if $install_clis; then
  echo "CLIs"
  for pair in claude:@anthropic-ai/claude-code codex:@openai/codex opencode:opencode-ai; do
    cmd="${pair%%:*}" pkg="${pair#*:}"
    if command -v "$cmd" >/dev/null; then
      say "$cmd already installed"
    else
      npm install -g "$pkg" >/dev/null && say "$cmd installed"
    fi
  done
fi

# --- Python, charting and slide tooling -------------------------------------
# The system Python is externally managed (PEP 668), so packages come from apt;
# python-pptx has no Ubuntu package and goes into ~/.local with pip instead.
# LibreOffice renders decks to PDF and poppler splits them into PNGs, so agents
# can check slides visually; Liberation fonts match Arial metrics.
if $install_clis; then
  echo "Python tools"
  apt_pkgs=(python3-pip python3-matplotlib python3-pandas libreoffice-impress poppler-utils fonts-liberation)
  missing=()
  for p in "${apt_pkgs[@]}"; do
    dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
  done
  if [ ${#missing[@]} -eq 0 ]; then
    say "apt packages already installed"
  else
    sudo apt-get update -qq >/dev/null
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${missing[@]}" >/dev/null
    say "installed ${missing[*]}"
  fi
  if python3 -c 'import pptx' 2>/dev/null; then
    say "python-pptx already installed"
  else
    python3 -m pip install --user --break-system-packages -q python-pptx && say "python-pptx installed"
  fi
fi

if ! command -v node >/dev/null; then
  echo "node is required to write the MCP configs" >&2
  exit 1
fi

# --- Symlinks for skills and agents ------------------------------------------
# link <path in repo> <target relative to that path's directory>
link() {
  local path="$ROOT/$1" target="$2"
  mkdir -p "$(dirname "$path")"
  if [ -L "$path" ]; then
    if [ "$(readlink "$path")" = "$target" ]; then
      say "$1 ok"
      return
    fi
    rm "$path"
  elif [ -e "$path" ]; then
    # A real directory here holds someone's own files; never delete it.
    say "$1 is a real directory, not a link; left alone (move its contents into .agents/)"
    return
  fi
  ln -s "$target" "$path"
  say "$1 -> $target"
}

echo "Skills and agents"
link .claude/skills   ../.agents/skills
link .claude/agents   ../.agents/agents
link .opencode/agents ../.agents/agents
# Codex and opencode read .agents/skills directly.

# --- MCP configs ------------------------------------------------------------
echo "MCP servers"
node - "$SRC/mcp.json" "$ROOT" <<'NODE'
const fs = require("fs");
const path = require("path");
const [src, root] = process.argv.slice(2);

const servers = JSON.parse(fs.readFileSync(src, "utf8")).servers ?? {};
for (const [name, s] of Object.entries(servers)) {
  if (!s.url === !s.command) {
    throw new Error(`${src}: server "${name}" needs exactly one of "url" or "command"`);
  }
  if (s.transport && !["http", "sse"].includes(s.transport)) {
    throw new Error(`${src}: server "${name}" has transport "${s.transport}"; use "http" or "sse"`);
  }
}
const entries = Object.entries(servers);

// Write only when the content changed, so reruns touch nothing.
function write(rel, text) {
  const file = path.join(root, rel);
  const old = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : null;
  if (old === text) return console.log(`  ${rel} unchanged`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, text);
  console.log(`  ${rel} ${old === null ? "created" : "updated"}`);
}

// Claude Code is registered with `claude mcp add` below, not from a file:
// servers in a project .mcp.json wait for approval in every new checkout.

// Codex: owned entirely by this script. JSON strings are valid TOML strings.
const q = JSON.stringify;
let toml = "# Generated by setup_agentic_tools.sh from .agents/mcp.json. Do not edit.\n";
for (const [name, s] of entries) {
  // Codex has no SSE client, so SSE servers go through a stdio bridge.
  const cmd = s.transport === "sse"
    ? { command: "npx", args: ["-y", "supergateway", "--sse", s.url, "--logLevel", "none"] }
    : s;
  toml += `\n[mcp_servers.${q(name)}]\n`;
  toml += cmd.url
    ? `url = ${q(cmd.url)}\n`
    : `command = ${q(cmd.command)}\nargs = [${(cmd.args ?? []).map(q).join(", ")}]\n`;
}
write(".codex/config.toml", toml);

// opencode: replace only the "mcp" key, keeping any other settings in the file.
const ocFile = path.join(root, "opencode.json");
let oc = { $schema: "https://opencode.ai/config.json" };
if (fs.existsSync(ocFile)) {
  try {
    oc = JSON.parse(fs.readFileSync(ocFile, "utf8"));
  } catch {
    console.log("  opencode.json is not plain JSON (comments?); left alone");
    process.exit(0);
  }
}
oc.mcp = {};
for (const [name, s] of entries) {
  oc.mcp[name] = s.url
    ? { type: "remote", url: s.url, enabled: true }
    : { type: "local", command: [s.command, ...(s.args ?? [])], enabled: true };
}
write("opencode.json", JSON.stringify(oc, null, 2) + "\n");
NODE

# Claude Code: "local" scope is private to this checkout and, because the user
# added it, never asks for approval. Re-adding replaces the old entry.
if command -v claude >/dev/null; then
  node -e '
    const s = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8")).servers ?? {};
    for (const [n, v] of Object.entries(s))
      console.log([n, v.url ? (v.transport ?? "http") : "stdio", v.url ?? v.command, ...(v.args ?? [])].join("\t"));
  ' "$SRC/mcp.json" |
  while IFS=$'\t' read -r name transport target rest; do
    (cd "$ROOT" && claude mcp remove --scope local "$name" >/dev/null 2>&1 || true)
    if [ "$transport" = stdio ]; then
      # shellcheck disable=SC2086  # rest holds the args, split on whitespace
      (cd "$ROOT" && claude mcp add --scope local "$name" -- "$target" $rest >/dev/null)
    else
      (cd "$ROOT" && claude mcp add --scope local --transport "$transport" "$name" "$target" >/dev/null)
    fi
    say "claude: $name registered (local scope)"
  done
else
  say "claude not installed; skipped"
fi

# Codex reads .codex/config.toml only in a trusted folder, and asks first
# otherwise. Mark this checkout trusted once.
codex_config="${CODEX_HOME:-$HOME/.codex}/config.toml"
if grep -qF "[projects.\"$ROOT\"]" "$codex_config" 2>/dev/null; then
  say "codex: folder already trusted"
else
  mkdir -p "$(dirname "$codex_config")"
  printf '\n[projects."%s"]\ntrust_level = "trusted"\n' "$ROOT" >> "$codex_config"
  say "codex: folder marked trusted in $codex_config"
fi

echo "Done. Edit .agents/ and rerun this script to apply changes."
