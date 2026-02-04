#!/usr/bin/env bash
set -euo pipefail

# macOS E2E smoke test for barked.sh.
#
# This uses Homebrew Bash because macOS ships Bash 3.2 by default.

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

BASH4="${BASH4:-/opt/homebrew/bin/bash}"
if [[ ! -x "$BASH4" ]]; then
  echo "ERROR: expected Bash 4+ at $BASH4"
  echo "Install it with: brew install bash"
  exit 1
fi

export BARKED_NO_UPDATE_CHECK=1

tmp_home="$(mktemp -d)"
tmp_audits="$(mktemp -d)"
trap 'rm -rf "$tmp_home" "$tmp_audits"' EXIT

export HOME="$tmp_home"

echo "--- barked --version"
"$BASH4" "$REPO_ROOT/scripts/barked.sh" --version

echo ""
echo "--- barked --audit (write to tmp audits)"
"$BASH4" "$REPO_ROOT/scripts/barked.sh" --audit --audit-dir "$tmp_audits" --no-update-check
test -s "$tmp_audits/audit-$(date +%Y-%m-%d).md"

echo ""
echo "--- barked --clean --dry-run (non-interactive selection)"
"$BASH4" "$REPO_ROOT/scripts/barked.sh" --clean --dry-run --clean-select user-caches,dev-cruft --no-update-check

echo "OK"

