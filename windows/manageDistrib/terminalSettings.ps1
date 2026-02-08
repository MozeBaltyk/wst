param(
    [Parameter(Mandatory = $true)]
    [string]$profileName,

    [Parameter(Mandatory = $true)]
    [string]$colorScheme,

    [string]$fontFace = "Consolas",
    [int]$fontSize = 14
)

# Handle old and new Windows Terminal settings paths
$terminalSettingsPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
)

$settingsPath = $terminalSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Warning "Windows Terminal settings.json not found (Windows Terminal may not be installed)."
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
    $profile_terminal | Add-Member -MemberType NoteProperty -Name colorScheme -Value $colorScheme -Force
    $profile_terminal | Add-Member -MemberType NoteProperty -Name opacity -Value 80 -Force
    $profile_terminal | Add-Member -MemberType NoteProperty -Name useAcrylic -Value $false -Force

    if (-not $profile_terminal.font) {
        $profile_terminal | Add-Member -MemberType NoteProperty -Name font -Value (@{}) -Force
    }

    $profile_terminal.font.face = $fontFace
    $profile_terminal.font.size = $fontSize

    Write-Host "Updated Terminal profile '$profileName' (theme=$colorScheme, font=$fontFace, size=$fontSize)"
}
else {
    throw "Profile '$profileName' not found"
}

# Save settings
$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
Write-Host "Saved Windows Terminal settings to $settingsPath"
