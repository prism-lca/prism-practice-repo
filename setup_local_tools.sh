#!/usr/bin/env bash
# Set up a Mac to work on this repo locally, without the dev container: the
# same tools the codespace image has (ghcr.io/prism-lca/prism-devcontainer),
# then setup_agent_config.sh for the MCP servers, skills and agents.
#
# Anything already installed is left alone, however it was installed.
# Homebrew and the Xcode command line tools are never installed for you,
# since both ask for your password; the script says how to get them.
# Safe to run any number of times.
#
# Usage: ./setup_local_tools.sh [--check]
#   --check  only report what's installed and what's missing

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_only=false
for arg in "$@"; do
  case "$arg" in
    --check) check_only=true ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
missing=0
need() { say "MISSING $1"; missing=$((missing + 1)); }

if [ "$(uname -s)" != Darwin ]; then
  echo "This script is for macOS; in a codespace the image has everything." >&2
  exit 1
fi

# --- Prerequisites the student installs by hand ------------------------------
echo "Prerequisites"
if xcode-select -p >/dev/null 2>&1; then
  say "Xcode command line tools ok (git $(git --version | awk '{print $3}'))"
else
  need "Xcode command line tools: run  xcode-select --install"
fi
if command -v brew >/dev/null; then
  say "Homebrew ok"
else
  need "Homebrew: see https://brew.sh (one command to paste in Terminal)"
fi
if [ "$missing" -gt 0 ]; then
  echo "Install the missing prerequisites above, then rerun this script."
  exit 1
fi

# --- Homebrew packages -------------------------------------------------------
echo "Homebrew packages"
for pair in node:node gh:gh python3:python; do
  cmd="${pair%%:*}" formula="${pair#*:}"
  if command -v "$cmd" >/dev/null; then
    say "$cmd ok"
  elif $check_only; then
    need "$cmd (brew install $formula)"
  else
    brew install "$formula" >/dev/null && say "$cmd installed"
  fi
done

# --- Agent CLIs and pptxgenjs, from npm ---------------------------------------
echo "npm packages"
npm_missing=()
for pair in claude:@anthropic-ai/claude-code codex:@openai/codex opencode:opencode-ai; do
  cmd="${pair%%:*}" pkg="${pair#*:}"
  if command -v "$cmd" >/dev/null; then
    say "$cmd ok"
  else
    npm_missing+=("$pkg")
  fi
done
if command -v npm >/dev/null && [ -d "$(npm root -g)/pptxgenjs" ]; then
  say "pptxgenjs ok"
else
  npm_missing+=(pptxgenjs)
fi
if [ ${#npm_missing[@]} -gt 0 ]; then
  if $check_only; then
    need "${npm_missing[*]} (npm install -g ${npm_missing[*]})"
  elif ! command -v npm >/dev/null; then
    need "${npm_missing[*]}: npm is missing, so install node first"
  else
    npm install -g "${npm_missing[@]}" >/dev/null && say "installed ${npm_missing[*]}"
  fi
fi

# --- Python packages ---------------------------------------------------------
# Homebrew's Python is externally managed (PEP 668), so packages go into your
# own ~/Library/Python with --user; that leaves Homebrew's copy untouched.
echo "Python packages"
if ! command -v python3 >/dev/null; then
  need "matplotlib, pandas, python-pptx: python3 is missing"
elif python3 -c 'import matplotlib, pandas, pptx' 2>/dev/null; then
  say "matplotlib, pandas, python-pptx ok"
elif $check_only; then
  need "matplotlib, pandas or python-pptx (pip install --user)"
else
  python3 -m pip install --user --break-system-packages -q matplotlib pandas python-pptx \
    && say "installed matplotlib, pandas, python-pptx"
fi

if $check_only; then
  if [ "$missing" -eq 0 ]; then
    echo "Everything is installed."
  else
    echo "$missing missing; run ./setup_local_tools.sh to install them."
  fi
  exit 0
fi
if [ "$missing" -gt 0 ]; then
  echo "Fix the missing items above, then rerun this script." >&2
  exit 1
fi

# --- This repo's MCP servers, skills and agents --------------------------------
"$ROOT/setup_agent_config.sh"
echo "Log in to each CLI the first time you use it (run claude, codex or opencode)."
