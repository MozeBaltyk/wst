# MENU: true
# TITLE: Set Desktop Wallpaper
# DESCRIPTION: Choose and apply a wallpaper from local assets

# Resolve paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WallpaperDir = Resolve-Path "$ScriptDir\..\..\assets\wallpapers"

if (-not (Test-Path $WallpaperDir)) {
    Write-Warning "Wallpaper directory not found: $WallpaperDir"
    return
}

# Discover images
$images = Get-ChildItem $WallpaperDir -File |
    Where-Object { $_.Extension -match '\.(jpg|jpeg|png|bmp|webp)$' }

if (-not $images) {
    Write-Host "No wallpapers found."
    return
}

# Build menu items
$items = [ordered]@{}
foreach ($img in $images) {
    $pretty = [IO.Path]::GetFileNameWithoutExtension($img.Name) -replace '[-_]', ' '
    $items[$img.FullName] = (Get-Culture).TextInfo.ToTitleCase($pretty)
}

# Show interactive selector
$selectedPath = Select-InteractiveItem `
    -Title "Select Desktop Wallpaper" `
    -Items $items `
    -Footer (Get-StatusFooter)

if (-not $selectedPath) {
    Write-Host "Cancelled."
}

# Wallpaper style: Fill
Set-ItemProperty "HKCU:\Control Panel\Desktop" WallpaperStyle 10
Set-ItemProperty "HKCU:\Control Panel\Desktop" TileWallpaper 0

# Native Windows API
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(
        int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Apply wallpaper
[Wallpaper]::SystemParametersInfo(20, 0, $selectedPath, 3) | Out-Null

Write-Host "Wallpaper applied:"
Write-Host "  $selectedPath" -ForegroundColor Green
