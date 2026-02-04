#!/usr/bin/env bash
set -euo pipefail

# Docker-based E2E smoke test for Barked (macOS/Linux script) in a sandbox.
#
# Requirements:
# - docker running (Docker Desktop or Colima)
#
# What it checks:
# - --version works
# - --audit writes a report to a writable directory (via --audit-dir)
# - --clean --dry-run works non-interactively (via --clean-select)

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
IMAGE="${BARKED_E2E_IMAGE:-ubuntu:24.04}"
VOL="${BARKED_E2E_VOLUME:-barked-e2e}"

echo "==> Using image: $IMAGE"
echo "==> Using volume: $VOL"

echo "==> Creating sandbox volume (if missing)"
docker volume create "$VOL" >/dev/null

echo "==> Copying repo into volume"
docker run --rm \
  -v "${VOL}:/barked" \
  -v "${REPO_ROOT}:/src:ro" \
  "${IMAGE}" \
  bash -lc 'set -euo pipefail; rm -rf /barked/*; cp -a /src/. /barked/'

echo "==> Running barked.sh smoke tests in container"
docker run --rm -i \
  -v "${VOL}:/barked" \
  -w /barked \
  "${IMAGE}" \
  bash -lc '
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y >/dev/null
    apt-get install -y --no-install-recommends bash ca-certificates curl python3 procps >/dev/null

    export HOME=/tmp/home
    mkdir -p "$HOME"

    export BARKED_NO_UPDATE_CHECK=1

    echo "--- barked --version"
    /bin/bash /barked/scripts/barked.sh --version

    echo ""
    echo "--- barked --audit (write to /tmp/audits)"
    rm -rf /tmp/audits
    mkdir -p /tmp/audits
    /bin/bash /barked/scripts/barked.sh --audit --audit-dir /tmp/audits
    test -s /tmp/audits/audit-$(date +%Y-%m-%d).md

    echo ""
    echo "--- barked --clean --dry-run (non-interactive selection)"
    /bin/bash /barked/scripts/barked.sh --clean --dry-run --clean-select user-caches,dev-cruft
  '

echo "==> OK"
