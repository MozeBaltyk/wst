# Sets up a WSL instance Ubuntu called "workstation" and runs bootstrap scripts.

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
#   .\installUbuntuLTS.ps1 -WSLName workstation -DistroName Ubuntu -LinuxUser ubuntu
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

# 2) Install new WSL instance from Ubuntu base
Write-Host "Installing a new WSL instance named '$WSLName' from $DistroName..."
wsl.exe --install --distribution $DistroName --name $WSLName --no-launch
# After attempting to install
$existingDistros = wsl.exe --list --quiet
if ($existingDistros -notcontains $WSLName) {
    Write-Host "❌ Installation failed. Could not find WSL instance '$WSLName'." -ForegroundColor Red
    exit 1
}

# 3) Create new Linux user with UID 1000
Write-Host "Creating user '$LinuxUser' with UID 1000..."
wsl.exe -d $WSLName -u root bash -ic "adduser --uid 1000 --disabled-password --gecos '' $LinuxUser"
wsl.exe -d $WSLName -u root bash -ic "usermod -aG sudo $LinuxUser"

# 4) Grant passwordless sudo
Write-Host "Granting passwordless sudo to '$LinuxUser'..."
wsl.exe -d $WSLName -u root bash -ic "echo '$LinuxUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$LinuxUser"
wsl.exe -d $WSLName -u root bash -ic "chmod 0440 /etc/sudoers.d/$LinuxUser"

# 5) Set DNS and default user in /etc/wsl.conf
Write-Host "Configuring DNS and setting default user..."
$wslConf = @"
[network]
generateResolvConf = false

[user]
default = $LinuxUser
"@
wsl.exe -d $WSLName -u root bash -ic "echo '$wslConf' > /etc/wsl.conf"
wsl.exe -d $WSLName -u root bash -ic "rm -f /etc/resolv.conf && echo 'nameserver 8.8.8.8' > /etc/resolv.conf && chattr +i /etc/resolv.conf"

# 6) Display Ubuntu version
Write-Host "Detecting the installed Ubuntu version..."
$version = wsl.exe -d $WSLName -u root bash -ic "grep PRETTY_NAME /etc/os-release"
Write-Host "This is your current Ubuntu version: $version"

# 7) Copy workspace scripts into WSL instance and bootstrap it
Write-Host "Copying workspace scripts into the WSL instance..."
$installerDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition     
$workspaceRoot  = Split-Path -Parent (Split-Path -Parent $installerDir)     # ../../scripts/manageDistrib
$destPath = Join-Path -Path ("\\wsl$\" + $WSLName + "\home\" + $LinuxUser) -ChildPath 'workstation'
if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }

# Copy all scripts directory to the WSL instance
Copy-Item -Path (Join-Path $workspaceRoot 'scripts\justfile') -Destination $destPath -Force
Copy-Item -Path (Join-Path $workspaceRoot 'scripts\bootstrap.sh') -Destination $destPath -Force
Copy-Item -Path (Join-Path $workspaceRoot 'scripts\bootstrap') -Destination (Join-Path $destPath 'bootstrap') -Recurse -Force

# Set ownership and mark scripts executable (use explicit chmod +x and retry if necessary)
Write-Host "Setting ownership and permissions inside the instance..."
$chownCmd = "chown -R ${LinuxUser}:${LinuxUser} /home/${LinuxUser}/workstation"
$chmodCmd = "chmod -R u+rwX /home/${LinuxUser}/workstation && find /home/${LinuxUser}/workstation -type f -name '*.sh' -exec chmod +x {} +"
# Run both commands as root inside the new instance
wsl.exe -d $WSLName -u root bash -lc "$chownCmd && $chmodCmd"

# Confirm permission bits for bootstrap.sh; retry chmod if necessary
$checkExec = wsl.exe -d $WSLName -u root bash -lc "test -x /home/${LinuxUser}/workstation/bootstrap.sh && echo OK || echo NOEXEC"
if ($checkExec.Trim() -ne 'OK') {
    Write-Warning "bootstrap.sh is not executable (retrying chmod inside instance)..."
    wsl.exe -d $WSLName -u root bash -lc "$chmodCmd"
}

# Run bootstrap commands inside the instance as the linux user
Write-Host "Running bootstrap scripts inside the instance (this may take some time)..."
$bootstrapCmd = 'cd ~/workstation && ./bootstrap.sh'
wsl.exe -d $WSLName -u $LinuxUser bash -lc $bootstrapCmd

# 8) Shut down WSL instance to apply changes
Write-Host "Shutting down the '$WSLName' instance to apply changes..."
wsl.exe --terminate $WSLName
