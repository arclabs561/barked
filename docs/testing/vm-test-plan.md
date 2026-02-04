## VM test plan (optional “full system” coverage)

The CI matrix (`.github/workflows/e2e.yml`) plus Docker E2E catches most regressions cheaply.
This VM plan is for the **small set of behaviors containers and CI runners do not model well**:

- systemd/launchd/Task Scheduler behavior over time
- firewall modules that depend on kernel networking state
- cron/launchd scheduling correctness and persistence
- privilege boundaries (root vs user vs SYSTEM)

### Guiding principle

Prefer **smoke + invariants** over “apply hardening for real” in VMs. Use `--audit`, `--dry-run`, and targeted module application where possible, and always record how to revert.

---

## Linux VM (systemd-real)

### Recommended

- **Ubuntu 24.04 VM** (UTM/QEMU), with systemd enabled.

### Scenarios to test

- **Scheduled cleaning**: configure schedule (cron) and confirm it runs, respects lock, and logs.
- **Firewall modules**: apply `firewall-inbound`, `firewall-stealth`, `firewall-outbound` (ufw/iptables) and verify with `ufw status` / `iptables -S`.
- **Auto-updates**: apply and verify timers/services (`unattended-upgrades`, `dnf-automatic`, etc.).
- **Revert**: apply one module and revert it; verify the previous state is restored.

### Suggested harness (manual)

1. Clone repo in the VM.
2. Run audit:
   - `./scripts/barked.sh --audit --audit-dir /tmp/barked-audits --no-update-check`
3. Apply a single module (interactive modify) and then revert via uninstall/modify.
4. Inspect logs under `audits/` and state under `~/.config/barked/`.

---

## Windows VM (real Task Scheduler + firewall)

### Recommended

- **Windows 11 VM** (UTM/QEMU) or any managed Windows VM.

### Scenarios to test

- **Scheduled cleaning**: `-CleanSchedule` and verify the task exists and triggers, lock works, and logs are written.
- **Firewall modules**: apply inbound/outbound policies and confirm system connectivity assumptions are still correct.
- **DNS changes**: verify adapter DNS and DoH behavior (Windows versions vary).
- **Revert**: apply and revert one module; verify state restoration.

### Suggested harness (manual)

1. Clone repo in the VM.
2. Audit:
   - `.\scripts\barked.ps1 -Audit -AuditDir $env:TEMP\\barked-audits -NoUpdateCheck`
3. Dry-run cleaner with deterministic selection:
   - `.\scripts\barked.ps1 -Clean -DryRun -CleanSelect "user-caches,dev-cruft" -NoUpdateCheck`

---

## macOS (real launchd + defaults)

macOS “emulation” isn’t practical; prefer **macOS hardware + CI runner**. If you need launchd persistence testing, use a dedicated macOS machine.

### Scenarios to test

- **launchd scheduled cleaning**: install the LaunchAgent and confirm it loads/unloads cleanly.
- **defaults write**: run modules that touch `defaults` and verify they behave across macOS versions.
- **Cleaner**: ensure the cleaner respects permissions, skips running browsers, and handles large caches.

