# Plan: shared dev container image

New codespaces for this repo spend ~3 minutes installing tools in the setup
script (from the creation log: npm CLIs ~77s, apt packages ~110s). Codespaces
prebuilds would cache that, but they need a GitHub Team or Enterprise plan for
org repos. Instead, bake the tools into a container image published to GitHub
Container Registry, which is free for a public repo and public package, and
which every repo in the org can use.

What goes where:

| Where | What |
|---|---|
| Image (`prism-lca/devcontainer`) | Node, gh, Claude Code, Codex, opencode, Python + matplotlib + pandas, python-pptx, LibreOffice Impress, poppler, Liberation fonts |
| Each repo (`.agents/` + `setup_agentic_tools.sh`) | MCP servers, skills, agents |

Why from a local clone: the codespace's `GITHUB_TOKEN` is scoped to this repo,
so it can't create `prism-lca/devcontainer` or push to it.

## Steps

1. Create a **public** repo `prism-lca/devcontainer` and add the three files
   below. Pushing `.github/workflows/` needs a token with the `workflow` scope.
2. Watch the first **Publish image** Actions run; it is the first real build of
   the Dockerfile (it was not test-built). Run it by hand from the Actions tab if
   needed (`workflow_dispatch`).
3. Make the package public: org **Packages** tab → `prism-devcontainer` →
   Package settings → Change visibility → Public. New packages start private.
4. In this repo, apply the two changes under "Changes in this repo" and commit.
   Do this only after step 3, or new codespaces fail to start.
5. Create a fresh codespace and check:
   `claude --version`, `codex --version`, `opencode --version`, `gh --version`,
   `python3 -c "import matplotlib, pandas, pptx"`, `soffice --version`,
   `pdftoppm -v`, and `claude mcp list` (shows `lca` and `dolt`).

## Files for `prism-lca/devcontainer`

### `Dockerfile`

```dockerfile
# Shared PRISM dev container image: the agent CLIs plus Python, charting and
# slide tooling, so codespaces don't spend minutes installing them.
# Repo-specific setup (MCP servers, skills, agents) stays in each repo.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Node.js (with npm and npx) from the official image.
COPY --from=node:24-bookworm-slim /usr/local/ /usr/local/

# The system Python is externally managed (PEP 668), so packages come from apt.
# LibreOffice renders decks to PDF and poppler splits them into PNGs, so agents
# can check slides visually; Liberation fonts match Arial metrics.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gh python3-pip python3-matplotlib python3-pandas \
      libreoffice-impress poppler-utils fonts-liberation \
 && rm -rf /var/lib/apt/lists/*

# CLIs and python-pptx go into vscode's home, so the user can update them
# without sudo (Claude Code updates itself in place).
USER vscode
ENV NPM_CONFIG_PREFIX=/home/vscode/.npm-global
ENV PATH=/home/vscode/.npm-global/bin:/home/vscode/.local/bin:$PATH
RUN npm install -g @anthropic-ai/claude-code @openai/codex opencode-ai \
 && python3 -m pip install --user --break-system-packages --no-cache-dir python-pptx
USER root
```

### `.github/workflows/publish.yml`

```yaml
# Builds the Dockerfile and publishes it to ghcr.io/<org>/prism-devcontainer,
# tagged "latest" and with the build date (e.g. 2026-10-17) for pinning.
# Rebuilds weekly too, so the agent CLIs don't go stale.
name: Publish image

on:
  push:
    branches: [main]
    paths: [Dockerfile, .github/workflows/publish.yml]
  schedule:
    - cron: "0 6 * * 1"
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Pick tags
        id: tags
        run: |
          image="ghcr.io/${GITHUB_REPOSITORY_OWNER,,}/prism-devcontainer"
          echo "tags=$image:latest,$image:$(date -u +%F)" >> "$GITHUB_OUTPUT"

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.tags.outputs.tags }}
```

### `README.md`

````markdown
# devcontainer

Shared dev container image for PRISM repos: Claude Code, Codex, opencode,
Node.js, the GitHub CLI, Python with matplotlib and pandas, python-pptx,
LibreOffice Impress and poppler.

Use it from a repo's `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/prism-lca/prism-devcontainer:latest"
}
```

Pin a dated tag (e.g. `:2026-10-17`) instead of `:latest` to stop updates.

The image is rebuilt on every change to the `Dockerfile` and weekly.
Repo-specific setup (MCP servers, skills, agents) belongs in each repo, not here.
````

## Changes in this repo

### `.devcontainer/devcontainer.json`

Replace the whole file. Node and gh now come from the image, and the installs
are gone, so only the per-repo setup runs at start.

```json
{
  "name": "PRISM practice",
  "image": "ghcr.io/prism-lca/prism-devcontainer:latest",
  "postStartCommand": "bash setup_agentic_tools.sh"
}
```

### `setup_agentic_tools.sh`

Drop the `--install-clis` flag and both install sections; the script keeps only
the symlink and MCP setup.

```diff
diff --git a/setup_agentic_tools.sh b/setup_agentic_tools.sh
index d530776..8eb7b12 100755
--- a/setup_agentic_tools.sh
+++ b/setup_agentic_tools.sh
@@ -11,71 +11,25 @@
 # (local scope) and marks the checkout trusted in ~/.codex/config.toml.
 # Safe to run any number of times: each run rebuilds the same result.
 #
-# Usage: ./setup_agentic_tools.sh [--install-clis]
-#   --install-clis  npm-install any of the three CLIs that are missing, and
-#                   install the Python, matplotlib and slide tools
-#                   (the devcontainer passes this; local runs usually don't)
+# The CLIs, Python and slide tools come from the shared dev container image
+# ghcr.io/prism-lca/prism-devcontainer (built in prism-lca/devcontainer).
+#
+# Usage: ./setup_agentic_tools.sh
 
 set -euo pipefail
 
 ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 SRC="$ROOT/.agents"
 
-install_clis=false
 for arg in "$@"; do
   case "$arg" in
-    --install-clis) install_clis=true ;;
-    -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
+    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
     *) echo "unknown option: $arg" >&2; exit 2 ;;
   esac
 done
 
 say() { printf '  %s\n' "$*"; }
 
-# --- CLIs -------------------------------------------------------------------
-if $install_clis; then
-  echo "CLIs"
-  # One npm install for all missing CLIs: npm fetches them in parallel.
-  missing_cmds=() missing_pkgs=()
-  for pair in claude:@anthropic-ai/claude-code codex:@openai/codex opencode:opencode-ai; do
-    cmd="${pair%%:*}" pkg="${pair#*:}"
-    if command -v "$cmd" >/dev/null; then
-      say "$cmd already installed"
-    else
-      missing_cmds+=("$cmd") missing_pkgs+=("$pkg")
-    fi
-  done
-  if [ ${#missing_pkgs[@]} -gt 0 ]; then
-    npm install -g "${missing_pkgs[@]}" >/dev/null && say "installed ${missing_cmds[*]}"
-  fi
-fi
-
-# --- Python, charting and slide tooling -------------------------------------
-# The system Python is externally managed (PEP 668), so packages come from apt;
-# python-pptx has no Ubuntu package and goes into ~/.local with pip instead.
-# LibreOffice renders decks to PDF and poppler splits them into PNGs, so agents
-# can check slides visually; Liberation fonts match Arial metrics.
-if $install_clis; then
-  echo "Python tools"
-  apt_pkgs=(python3-pip python3-matplotlib python3-pandas libreoffice-impress poppler-utils fonts-liberation)
-  missing=()
-  for p in "${apt_pkgs[@]}"; do
-    dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
-  done
-  if [ ${#missing[@]} -eq 0 ]; then
-    say "apt packages already installed"
-  else
-    sudo apt-get update -qq >/dev/null
-    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends "${missing[@]}" >/dev/null
-    say "installed ${missing[*]}"
-  fi
-  if python3 -c 'import pptx' 2>/dev/null; then
-    say "python-pptx already installed"
-  else
-    python3 -m pip install --user --break-system-packages -q python-pptx && say "python-pptx installed"
-  fi
-fi
-
 if ! command -v node >/dev/null; then
   echo "node is required to write the MCP configs" >&2
   exit 1
```

## Notes

- Pointing at `:latest` gives every repo updates automatically, but a bad image
  breaks them all at once. Pin a dated tag (e.g. `:2026-10-17`) to opt out.
- The image rebuilds weekly so the CLIs stay current; Claude Code also updates
  itself, since the CLIs are installed in the `vscode` user's home.
