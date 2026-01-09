# Sets up a WSL instance with NixOS called "workstation" and runs bootstrap scripts.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$WSLName = "workstation",

    [Parameter(Mandatory=$false)]
    [string]$DistroName = "Ubuntu",

    [Parameter(Mandatory=$false)]
    [string]$LinuxUser = "ubuntu",

    [Parameter(Mandatory=$false)]
    [bool]$Legacy = $true
)

# You can run this script directly, e.g.:
#   .\installNixOS.ps1 -WSLName workstation -DistroName NixOS -LinuxUser nixos -Legacy $true
# Or let `menu.ps1` invoke it with named parameters.

# Ensure we're running from a Windows path (avoid WSL UNC path translation problems when calling wsl.exe)
Set-Location -Path $env:USERPROFILE

# 1) Check if instance do not already exists before attempting installation
Write-Host "Check if instance '$WSLName' do not already exists..."
$existingDistros = wsl.exe --list --quiet
if ($existingDistros -contains $WSLName) {
    Write-Host "❌ A WSL instance named '$WSLName' already exists. Please uninstall it first or choose a different name." -ForegroundColor Red
    exit 1
}

# 2) Get latest version of NixOS WSL distro from github and download it
Write-Host "Downloading latest NixOS WSL distribution..."
$LATEST_VERSION_URL = 'https://api.github.com/repos/nix-community/NixOS-WSL/releases/latest'
$headers = @{ 'User-Agent' = 'PowerShell' }
$LATEST_VERSION = (Invoke-RestMethod -Uri $LATEST_VERSION_URL -Headers $headers).tag_name
$DOWNLOAD_URL = "https://github.com/nix-community/NixOS-WSL/releases/download/$LATEST_VERSION/nixos.wsl"
$OutFile = Join-Path $env:TEMP "nixos.wsl"
Start-BitsTransfer -Source $DOWNLOAD_URL -Destination $OutFile

# 3) Install new WSL instance from Ubuntu base
Write-Host "Installing a new WSL instance named '$WSLName' from $DistroName..."
wsl --install --from-file $OutFile --name $WSLName --no-launch
# After attempting to install
$existingDistros = wsl.exe --list --quiet
if ($existingDistros -notcontains $WSLName) {
    Write-Host "❌ Installation failed. Could not find WSL instance '$WSLName'." -ForegroundColor Red
    exit 1
}
Write-Host "✅ WSL instance '$WSLName' installed successfully."

# 4) Update NixOS instance
Write-Host "Configuring NixOS instance..."  
wsl.exe -d $WSLName -- bash -lc 'sudo nix-channel --update && sudo nixos-rebuild switch'