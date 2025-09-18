#!/bin/zsh
# system-scan.sh
# Full system health scan with restart & update check (read-only)
LOG="$HOME/Desktop/system_scan_$(date +%Y%m%d_%H%M%S).txt"
sec(){ echo "\n=== $1 === $(date)"; }

{
  sec "SYSTEM INFO"
  sw_vers
  uname -a
  uptime

  sec "CPU & MEMORY"
  top -l 1 -n 10 | head -n 20
  vm_stat

  sec "DISK HEALTH"
  df -h /
  diskutil info /

  sec "SECURITY STATUS"
  fdesetup status
  /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || echo "Firewall status requires admin to query."
  system_profiler SPConfigurationProfileDataType | grep -i "FileVault" || true

  sec "RESTART STATUS"
  echo "Last reboot:"
  who -b || true
  needs_reboot=$(softwareupdate -l 2>&1 | grep -i restart || true)
  if [ -n "$needs_reboot" ]; then echo "Restart required."; else echo "No restart required."; fi

  sec "PENDING UPDATES"
  softwareupdate -l 2>/dev/null || echo "No updates available."

  sec "SYSTEM LOG ERRORS (last 24h)"
  log show --predicate 'eventType == logEvent' --last 1d --info 2>/dev/null | grep -i "error" | tail -n 50 || true
} > "$LOG" 2>&1

echo "System scan complete. Log saved -> $LOG"
