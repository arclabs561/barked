#!/usr/bin/env bash
set -euo pipefail

# Native Linux E2E smoke test for barked.sh (no containers).
# Intended for CI runners where Bash 4+ and python3 exist.

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

export BARKED_NO_UPDATE_CHECK=1

tmp_home="$(mktemp -d)"
tmp_audits="$(mktemp -d)"
trap 'rm -rf "$tmp_home" "$tmp_audits"' EXIT

export HOME="$tmp_home"

echo "--- barked --version"
/bin/bash "$REPO_ROOT/scripts/barked.sh" --version

echo ""
echo "--- barked --audit (write to tmp audits)"
/bin/bash "$REPO_ROOT/scripts/barked.sh" --audit --audit-dir "$tmp_audits"
test -s "$tmp_audits/audit-$(date +%Y-%m-%d).md"

echo ""
echo "--- barked --clean --dry-run (non-interactive selection)"
/bin/bash "$REPO_ROOT/scripts/barked.sh" --clean --dry-run --clean-select user-caches,dev-cruft

echo "OK"

