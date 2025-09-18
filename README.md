# System Scan (Windows + macOS)

Collects OS info, uptime, CPU/RAM, disk, security status, **restart required**, and **pending updates** — writes a log for tickets/escalation.

## Safety
- **Read-only**: does **not** reboot or install updates.
- Windows: `PSWindowsUpdate` is optional; if missing, update listing is skipped.
- macOS: some checks may prompt for admin; skipping is safe.

## Usage

### Windows (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File .\system-scan.ps1
```

### macOS (zsh)
```bash
chmod +x ./system-scan.sh
./system-scan.sh
```

> ⚠️ Sanitized demo scripts — no real credentials or company data.
