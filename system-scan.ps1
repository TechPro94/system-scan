# system-scan.ps1
# Full system health scan with restart & update check (read-only)
$stamp = (Get-Date -Format 'yyyyMMdd_HHmmss')
$log = "$env:PUBLIC\system_scan_$stamp.txt"
function Section($name){ "`n=== $name === $(Get-Date)`n" | Out-File $log -Append }

Section "SYSTEM INFO"
Get-ComputerInfo | Out-File $log -Append
systeminfo | Out-File $log -Append
Get-CimInstance Win32_OperatingSystem | Select-Object LastBootUpTime | Out-File $log -Append

Section "CPU & MEMORY"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Out-File $log -Append
Get-Counter '\Memory\Available MBytes' | Out-File $log -Append

Section "DISK HEALTH"
Get-PSDrive -PSProvider FileSystem | Out-File $log -Append
Get-CimInstance Win32_DiskDrive | Select-Object Model,Status,Size | Out-File $log -Append

Section "SECURITY STATUS"
try { Get-MpComputerStatus | Out-File $log -Append } catch { "Defender status unavailable." | Out-File $log -Append }
(Get-NetFirewallProfile) | Out-File $log -Append

Section "RESTART STATUS"
$pending = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction SilentlyContinue)
if ($pending) { "Restart is pending." } else { "No restart required." } | Out-File $log -Append

Section "PENDING UPDATES"
try {
  Import-Module PSWindowsUpdate -ErrorAction Stop
  Get-WindowsUpdate -MicrosoftUpdate -IgnoreUserInput -ErrorAction SilentlyContinue |
    Select-Object Title, KB, Size | Out-File $log -Append
} catch {
  "PSWindowsUpdate module not installed — skipping update listing." | Out-File $log -Append
}

Section "EVENT LOG ERRORS (last 24h)"
Get-WinEvent -FilterHashtable @{LogName='System';Level=2;StartTime=(Get-Date).AddDays(-1)} -MaxEvents 20 |
  Format-List | Out-File $log -Append

Write-Host "System scan complete. Log saved -> $log"
