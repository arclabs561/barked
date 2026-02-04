## Docker E2E smoke test

This is a **sandboxed** end-to-end smoke test for `scripts/barked.sh` using Docker/Colima.

### Run

```bash
./tests/e2e/docker-e2e.sh
```

### Notes

- The test runs Barked inside an Ubuntu container with a throwaway `HOME`.
- It disables passive update notifications via `BARKED_NO_UPDATE_CHECK=1`.
- It writes audit output to `/tmp/audits` inside the container using `--audit-dir`, so it does not rely on a writable repo checkout.

## Cross-platform CI smoke tests

In addition to the Docker test, the repo includes minimal per-OS smoke tests:

- **Linux**: `tests/e2e/linux-e2e.sh` (native runner)
- **macOS**: `tests/e2e/macos-e2e.sh` (uses Homebrew Bash)
- **Windows**: `tests/e2e/windows-e2e.ps1` (PowerShell audit + cleaner dry-run)

