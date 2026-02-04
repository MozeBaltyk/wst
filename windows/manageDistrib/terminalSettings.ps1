param(
    [Parameter(Mandatory=$true)]
    [string]$profileName
)

# Handle old and new Windows Terminal settings paths
$terminalSettingsPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
)

$settingsPath = $terminalSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Warning "Windows Terminal settings.json not found"
    return
}

# Backup before editing
$backupPath = "$settingsPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $settingsPath $backupPath -Force
Write-Host "Backup created: $backupPath"

# Load settings
$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# Make sure list exists
if (-not $settings.profiles.list) { $settings.profiles.list = @() }

# Find profile in list
$profile_terminal = $settings.profiles.list | Where-Object { $_.name -eq $profileName }

if ($null -ne $profile_terminal) {

    # Add missing properties if they don't exist
    if (-not $profile_terminal.PSObject.Properties.Match('colorScheme')) {
        $profile_terminal | Add-Member -MemberType NoteProperty -Name colorScheme -Value "One Half Dark"
    }
    else {
        $profile_terminal.colorScheme = "One Half Dark"
    }

    if (-not $profile_terminal.PSObject.Properties.Match('opacity')) {
        $profile_terminal | Add-Member -MemberType NoteProperty -Name opacity -Value 85
    }
    else {
        $profile_terminal.opacity = 85
    }

    if (-not $profile_terminal.PSObject.Properties.Match('useAcrylic')) {
        $profile_terminal | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $true
    }
    else {
        $profile_terminal.useAcrylic = $true
    }

    Write-Host "Updated Terminal profile '$profileName'"
}
else {
    Write-Warning "Profile '$profileName' not found"
}

# Save settings
$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
Write-Host "Saved Windows Terminal settings to $settingsPath"

return
