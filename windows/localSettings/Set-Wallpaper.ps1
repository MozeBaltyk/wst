# MENU: true
# TITLE: Set Wallpaper
# DESCRIPTION: Setup desktop wallpapers from local files

# Resolve image path relative to this script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ImagePath = Resolve-Path "$ScriptDir\..\..\assets\wallpapers\SoM-1920x1080_2.jpg"

# Set wallpaper style (Fill)
Set-ItemProperty "HKCU:\Control Panel\Desktop" WallpaperStyle 10
Set-ItemProperty "HKCU:\Control Panel\Desktop" TileWallpaper 0

# Native Windows API call
Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(
        int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Apply wallpaper
[Wallpaper]::SystemParametersInfo(20, 0, $ImagePath.Path, 3) | Out-Null

return