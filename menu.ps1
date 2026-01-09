# Simple console menu
$distros = @{
    1 = @{Name='Ubuntu 24.04 LTS'; DistroName='Ubuntu-24.04';     InstallerScript='installUbuntuLTS.ps1'; LinuxUser = "ubuntu"; legacy = $false}
    2 = @{Name='Oracle 9.5';       DistroName='OracleLinux_9_5';  InstallerScript='installOracle.ps1';    LinuxUser = "oracle"; legacy = $true}
    3 = @{Name='Oracle 8.10';      DistroName='OracleLinux_8_10'; InstallerScript='installOracle.ps1';    LinuxUser = "oracle"; legacy = $true}
    4 = @{Name='NixOS';            DistroName='NixOS';            InstallerScript='installNixOS.ps1';     LinuxUser = "nixos";  legacy = $false}
    0 = @{Name='Exit';             DistroName=$null;              InstallerScript=$null; LinuxUser = $null}
}

function Show-Menu {
    while ($true) {
        Clear-Host
        # Ask user what to do
        do { $action = Read-Host "Choose action: [I]nstall, [U]ninstall, [C]ancel" } while (-not ($action) -or ($action -notmatch '^[iuc]$'))

        switch ($action.ToUpper()) {
            'I' {
                # Show the distro list in menu mode for installation
                $distrosMap = Show-Distros
                if (-not $distrosMap) { Read-Host "Press Enter to continue..."; continue }

                $selectedKey = Read-Selection -Map $distrosMap -Prompt "Enter number"
                if (-not $selectedKey) { Write-Host "Cancelled."; continue }

                Manage-Distrib -choice $selectedKey
            }
            'U' {
                # Show the list of WSL available for uninstalling
                $wslMap = Show-WSLs
                if (-not $wslMap) { Read-Host "Press Enter to continue..."; continue }

                $instanceName = Read-Selection -Map $wslMap -Prompt "Enter number"
                if ($null -eq $instanceName) { Write-Host "Cancelled."; continue }

                # Normalize and trim (strip control chars) before uninstall
                $instanceName = ($instanceName -replace '[\u0000-\u001F\u007F]', '').Trim()
                Write-Host "DEBUG: Selected instance: '$instanceName'"

                Uninstall-WSL -InstanceName $instanceName
            }
            'C' { Write-Host "Exiting."; return }
        }
    }
}

function Show-WSLs {
    Clear-Host
    Write-Host "Choose a WSL instance to manage:`n"
    $instancesRaw = wsl.exe --list --quiet 2>$null
    $instances = @()
    if ($instancesRaw) { $instances = ($instancesRaw -split "`r?`n") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } }

    $wslMap = @{}
    # Always expose a 0 => Cancel option
    $wslMap[0] = $null

    if (-not $instances -or $instances.Count -eq 0) {
        Write-Host "No WSL instances found."
        return $wslMap
    }

    for ($i = 0; $i -lt $instances.Count; $i++) {
        $idx = $i + 1
        Write-Host " [$idx]  $($instances[$i])"
        $wslMap[$idx] = $instances[$i]
    }

    Write-Host " [0]  Cancel"
    return $wslMap
} 

function Show-Distros {
    Clear-Host
    Write-Host "Choose a Linux to install:`n"
    $keys = ($distros.Keys | Sort-Object) | Where-Object { $_ -ne 0 }
    $map = @{}
    for ($i = 0; $i -lt $keys.Count; $i++) {
        $idx = $i + 1
        $key = $keys[$i]
        Write-Host " [$idx]  $($distros[$key].Name)"
        $map[$idx] = $key
    }
    # Add explicit Cancel entry so 0 is a valid key
    $map[0] = $null
    Write-Host " [0]  Cancel"
    return $map
}

# Generic helper: read a numeric selection from a numeric->value map and return the mapped value or $null for Cancel
function Read-Selection {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Map,
        [Parameter(Mandatory=$false)][string]$Prompt = "Enter number"
    )
    if (-not $Map -or $Map.Count -eq 0) { return $null }

    # Initialize parsed so we can pass it by reference to TryParse
    $parsed = 0
    $ok = $false
    do {
        $input = Read-Host $Prompt
        $ok = [int]::TryParse($input, [ref]$parsed)
    } while (-not $ok -or -not $Map.ContainsKey([int]$parsed))

    if ([int]$parsed -eq 0) { return $null }
    return $Map[[int]$parsed]
} 

function Manage-Distrib {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Choice
    )

    if (-not $distros.ContainsKey($Choice)) { Write-Warning "Invalid selection."; return }
    $meta = $distros[$Choice]
    # Prompt for a WSL name if not configured and legacy is false
    if (-not $meta.WSLName -and $meta.legacy -eq $false) {
        $defaultName = if ($meta.DistroName) { $meta.DistroName } else { 'WSL-Instance' }
        $input = Read-Host "Enter WSL instance name [$defaultName]"
        if ([string]::IsNullOrWhiteSpace($input)) {
            $meta.WSLName = $defaultName
        } else {
            # remove control characters and trim
            $meta.WSLName = ($input -replace '[\u0000-\u001F\u007F]', '').Trim()
        }

        if (-not $meta.WSLName) {
            Write-Warning "No valid WSL name provided. Aborting."
            Read-Host "Press Enter to continue..."
            return
        }

        Write-Host "Selected: $($meta.Name)"
        Write-Host "Using WSL name: $($meta.WSLName)"
    }
    else {
        # Use DistroName as WSLName for legacy installs
        if (-not $meta.WSLName) {
            $meta.WSLName = $meta.DistroName
        }
    }

    # Check installer script
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot }
    $altDir  = Join-Path -Path $scriptDir -ChildPath 'windows\manageDistrib'
    $fullPath = Join-Path -Path $altDir -ChildPath $meta.InstallerScript

    if (-not $meta.InstallerScript) {
        Write-Warning "No installer configured for $($meta.Name)."
        Read-Host "Press Enter to continue..."
        return
    }

    if (-not (Test-Path $fullPath)) {
        Write-Warning "Installer script '$($meta.InstallerScript)' not found in script directory $altDir."
        Read-Host "Press Enter to continue..."
        return
    }

    Write-Host "Invoking installer script: $fullPath -WSLName $($meta.WSLName) -DistroName $($meta.DistroName) -LinuxUser $($meta.LinuxUser) -Legacy $([bool]$meta.legacy)"
    Write-Host "Installing $($meta.Name)..."

    # Invoke the installer script with parameters
    try {
        & $fullPath -WSLName $meta.WSLName -DistroName $meta.DistroName -LinuxUser $meta.LinuxUser -Legacy ([bool]$meta.legacy)
    } catch {
        Write-Warning "Installer failed: $_"
    }

    Read-Host "Press Enter to continue..."
}

function Uninstall-WSL {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$InstanceName
    )

    # Remove control chars (nulls/newlines etc.) and trim
    $InstanceName = ($InstanceName -replace '[\u0000-\u001F\u007F]', '').Trim()
    Write-Host "DEBUG: InstanceName cleaned: '$InstanceName' (length: $($InstanceName.Length))"

    $confirm = Read-Host "Are you sure you want to UNINSTALL and remove all data for '$InstanceName'? Type 'YES' to confirm"
    if ($confirm -ne 'YES') { Write-Host "Uninstall cancelled."; Read-Host "Press Enter to continue..."; return }

    # terminate instance
    $termArgs = @('--terminate', $InstanceName)
    $terminateOut = & wsl.exe @termArgs 2>&1
    $terminateCode = $LASTEXITCODE
    if ($terminateCode -ne 0) { Write-Warning "Terminate failed (code $terminateCode): $terminateOut" }

    # unregister instance
    $unregArgs = @('--unregister', $InstanceName)
    $unregisterOut = & wsl.exe @unregArgs 2>&1
    $unregisterCode = $LASTEXITCODE
    if ($unregisterCode -ne 0) {
        Write-Warning "Unregister failed (code $unregisterCode): $unregisterOut"
    } else {
        Write-Host "Unregistered WSL instance '$InstanceName'. Current instances:"
        wsl.exe --list
    }

    Read-Host "Press Enter to continue..."
}

# Start the menu
Show-Menu