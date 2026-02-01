# Barked

Cross-platform security hardening wizard. Pure Bash (macOS/Linux) and PowerShell (Windows), zero external dependencies.

## Commands

```bash
# Run the wizard
./scripts/barked.sh                # Interactive hardening
./scripts/barked.sh --clean        # System cleaner
./scripts/barked.sh --audit        # Non-destructive security audit
./scripts/barked.sh --dry-run      # Preview without applying
./scripts/barked.sh --uninstall    # Revert all hardening
./scripts/barked.sh --modify       # Add/remove modules
./scripts/barked.sh --update       # Self-update

# Lint
shellcheck scripts/barked.sh
```

No build step. No test suite. Validation is manual runs + shellcheck.

## Architecture

Two main scripts with feature parity:
- `scripts/barked.sh` — Bash 4+, ~6,600 lines, v2.1.2
- `scripts/barked.ps1` — PowerShell 5+, ~4,000 lines, v1.0.0

### Module Pattern (Four Rings)

Every security module has four functions following this convention:

```
check_<module_id>()  → returns CHECK_STATUS (PASS|FAIL|MANUAL|N/A) + CHECK_FINDING
apply_<module_id>()  → makes the change, saves previous value to state
verify_<module_id>() → confirms change took effect
revert_<module_id>() → undoes change, restores previous value
```

25 modules total. Module IDs use kebab-case: `disk-encrypt`, `firewall-inbound`, `dns-secure`, `mac-rotate`, `ssh-harden`, etc.

### Profiles

- **Standard** (7 modules) — essential baseline
- **High** (15 modules) — standard + active defense
- **Paranoid** (25 modules) — high + obfuscation & opsec
- **Advanced** — custom questionnaire maps threat model → modules

### State Management

JSON state file at `~/.config/barked/state.json` (user) with fallback to `${SCRIPT_DIR}/../state/hardening-state.json` (project). Legacy path `/etc/hardening-state.json` auto-migrates. Python 3 used for JSON parsing when available; falls back to live system detection.

### Cross-Platform Branching

Each `apply_*()` / `check_*()` function has OS-specific branches:
- macOS: `defaults write`, `launchctl`, `pfctl`
- Linux: `systemctl`, `ufw`, `gsettings`
- Windows (PowerShell): registry, GPO, `netsh`

## Key Files

| File | Purpose |
|------|---------|
| `scripts/barked.sh` | Main wizard (Bash) |
| `scripts/barked.ps1` | Main wizard (PowerShell) |
| `scripts/weekly-audit.sh` | macOS weekly audit reporter |
| `install.sh` | macOS/Linux installer |
| `install.ps1` | Windows installer |

## Git Workflow

Feature branches use git worktrees at `.worktrees/<feature-name>/`. Active worktree: `feature/scheduled-cleaner`.

```bash
git worktree list                  # See active worktrees
git worktree add .worktrees/<name> -b feature/<name>
```

Releases via `gh release create` with both scripts as assets.

## Gotchas

- **Bash 4+ required on macOS** — ships with 3.2; users need `brew install bash`. Script uses associative arrays (`declare -A`).
- **Interactive only** — no silent/unattended mode by design. Every security decision requires human confirmation.
- **Privilege model is all-or-nothing** — script checks for root/admin at startup, lists which modules need elevation, asks user to re-run with `sudo`.
- **No external dependencies** — don't introduce any. The scripts must run on a stock OS install.
- **Idempotent** — safe to re-run. `check_*()` prevents re-applying already-applied changes.
- **`set -euo pipefail`** — strict mode is on. All globals are `readonly`. Unset variables and pipe failures are fatal.
- **Logs go to `audits/`** — gitignored. Format is markdown with timestamps.
- **Baseline snapshots in `baseline/`** — gitignored. Used by weekly audit to detect drift.
