# Get total system RAM in GB
$totalRamBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$totalRamGB = [math]::Floor($totalRamBytes / 1GB)

# Decide WSL memory cap
if ($totalRamGB -le 16) {
    $wslMemoryGB = [math]::Floor($totalRamGB * 0.5)
}
elseif ($totalRamGB -le 32) {
    $wslMemoryGB = 24
}
else {
    # For 64GB+ systems
    $wslMemoryGB = [math]::Min(32, [math]::Floor($totalRamGB * 0.5))
}

# Paths
$wslConfigPath = "$env:USERPROFILE\.wslconfig"

# Backup existing config
if (Test-Path $wslConfigPath) {
    $backupPath = "$wslConfigPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $wslConfigPath $backupPath
    Write-Host "Backup created: $backupPath"
}

# Build .wslconfig
$wslConfig = @"
[wsl2]
networkingMode=mirrored
dnsTunneling=true
autoProxy=true
nestedVirtualization=true
memory=${wslMemoryGB}GB

[experimental]
hostAddressLoopback=true
autoMemoryReclaim=gradual
bestEffortDnsParsing=true
"@

# Write file
Set-Content -Path $wslConfigPath -Value $wslConfig -Encoding UTF8

Write-Host ".wslconfig written with memory=${wslMemoryGB}GB (System RAM: ${totalRamGB}GB)"

# Restart WSL
Write-Host "Restarting WSL..."
wsl --shutdown

Write-Host "Done. Start WSL again to apply the new settings."
