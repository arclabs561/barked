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

