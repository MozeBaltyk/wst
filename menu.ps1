# =========================
# Data
# =========================

$distros = @(
    [PSCustomObject]@{ Name='Ubuntu 24.04 LTS'; DistroName='Ubuntu-24.04'; InstallerScript='installUbuntuLTS.ps1'; LinuxUser='ubuntu'; Legacy=$false; TerminalTheme='Dark+' },
    [PSCustomObject]@{ Name='Fedora Linux 43'; DistroName='FedoraLinux-43'; InstallerScript='installFedoraLinux.ps1'; LinuxUser='fedora'; Legacy=$false; TerminalTheme='One Half Dark' },
    [PSCustomObject]@{ Name='NixOS';            DistroName='NixOS';            InstallerScript='installNixOS.ps1';     LinuxUser='nixos';  Legacy=$false; TerminalTheme='Campbell'}
    # I do not manage legacy distrib in WSL
    # [PSCustomObject]@{ Name='Oracle 9.5';       DistroName='OracleLinux_9_5'; InstallerScript='installOracle.ps1';    LinuxUser='oracle'; Legacy=$true;  TerminalTheme='One Half Dark'},
    # [PSCustomObject]@{ Name='Oracle 8.10';      DistroName='OracleLinux_8_10'; InstallerScript='installOracle.ps1';    LinuxUser='oracle'; Legacy=$true; TerminalTheme='One Half Dark' }
    )

# =========================
# UI Helpers
# =========================

function Select-InteractiveItem {
    param(
        [Parameter(Mandatory)][string]    $Title,
        [Parameter(Mandatory)][System.Collections.IDictionary] $Items,
        [string] $Footer,
        $KeyList  # <-- Remove [string[]] to allow mixed types (int and string)
    )

    if (-not $Items -or $Items.Count -eq 0) { return $null }

    if (-not $KeyList) {
        $KeyList = @($Items.Keys)
    }
    $index = 0

    while ($true) {
        Clear-Host
        Write-Host $Title -ForegroundColor Cyan
        Write-Host ""

        for ($i = 0; $i -lt $KeyList.Count; $i++) {
            $currentKey = $KeyList[$i]
            $displayValue = $Items[$currentKey]

            if ($i -eq $index) {
                Write-Host " > $displayValue" -ForegroundColor Yellow
            } else {
                Write-Host "   $displayValue"
            }
        }

        Write-Host ""
        Write-Host " [Up/Down] navigate / [Enter] select / [Esc] cancel" -ForegroundColor DarkGray

        if ($Footer) {
            Write-Host ""
            Write-Host $Footer -ForegroundColor DarkGray
        }

        $key = [Console]::ReadKey($true)

        switch ($key.Key) {
            'UpArrow'   { if ($index -gt 0) { $index-- } }
            'DownArrow' { if ($index -lt $KeyList.Count - 1) { $index++ } }
            'Escape'    { return $null }
            'Enter'     { return $KeyList[$index] }
        }
    }
}

function Get-StatusFooter {
    try {
        $wslCount = ((wsl.exe --list --quiet 2>$null) -replace '\x00', '' |
                    Where-Object { $_.Trim() }).Count
    } catch { $wslCount = 0 }
    try { $os = Get-CimInstance Win32_OperatingSystem; $win="$($os.Caption) ($($os.BuildNumber))" } catch { $win="Unknown" }
    return "WSL instances: $wslCount | $win"
}

# =========================
# Installer / Uninstaller
# =========================

function Manage-Distrib {
    param(
        [Parameter(Mandatory=$true)][int]$Index
    )

    if ($Index -lt 0 -or $Index -ge $distros.Count) {
        Write-Warning "Invalid selection."
        return
    }

    $meta = $distros[$Index]

    # Prompt for WSL instance name if not legacy
    if ($meta.Legacy -eq $false) {
        $defaultName = $meta.DistroName
        $userInput = Read-Host "Enter WSL instance name [$defaultName]"
        $cleanInput = ($userInput -replace '[\u0000-\u001F\u007F]', '').Trim()
        $wslName = if ([string]::IsNullOrWhiteSpace($cleanInput)) { $defaultName } else { $cleanInput }

        if (-not $wslName) {
            Write-Warning "No valid WSL name provided. Aborting."
            Read-Host "Press Enter to continue..."
            return
        }
    } else {
        # Legacy: use DistroName as WSLName
        $wslName = $meta.DistroName
    }

    # Prompt for username
    $defaultUser = $meta.LinuxUser
    $userInput = Read-Host "Enter Linux username [$defaultUser]"
    $cleanInput = ($userInput -replace '[\u0000-\u001F\u007F]', '').Trim()
    $linuxUser = if ([string]::IsNullOrWhiteSpace($cleanInput)) { $defaultUser } else { $cleanInput }

    # Prompt for Terminal theme
    $defaultTheme = $meta.TerminalTheme
    $userTheme = Read-Host "Enter terminal theme [$defaultTheme]"
    $themeToUse = if ([string]::IsNullOrWhiteSpace($userTheme)) { $defaultTheme } else { $userTheme }

    # Check installer script
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $altDir = Join-Path $scriptDir 'windows\manageDistrib'
    $fullPath = Join-Path $altDir $meta.InstallerScript
    $terminalScriptPath = Join-Path $altDir 'terminalSettings.ps1'

    if (-not $meta.InstallerScript) {
        Write-Warning "No installer configured for $($meta.Name)."
        Read-Host "Press Enter to continue..."
        return
    }
    if (-not (Test-Path $fullPath)) {
        Write-Warning "Installer script '$($meta.InstallerScript)' not found in $altDir."
        Read-Host "Press Enter to continue..."
        return
    }
    if (-not (Test-Path $terminalScriptPath)) {
        Write-Warning "Terminal settings script '$($terminalScriptPath)' not found in $altDir."
        Read-Host "Press Enter to continue..."
        return
    }

    Write-Host "Installing $($meta.Name) as WSL instance '$wslName'..."
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Install WSL distribution
    try {
        & $fullPath `
            -WSLName $wslName `
            -DistroName $meta.DistroName `
            -LinuxUser $linuxUser `
            -Legacy ([bool]$meta.Legacy) `
            -ErrorAction Stop
    }
    catch {
        Write-Warning "Installer failed: $_"
    }
    finally {
        $stopwatch.Stop()
        Write-Host ("Installation completed in {0:N2} seconds" -f $stopwatch.Elapsed.TotalSeconds)
    }

    # Update terminal profile
    try {
        & $terminalScriptPath -profileName $wslName -colorScheme $themeToUse -ErrorAction Stop
        Write-Host "Terminal profile updated successfully"
    }
    catch {
        Write-Warning "Terminal profile update failed: $_"
    }
    Start-Sleep -Seconds 2

    Read-Host "Press Enter to continue..."
}

function Uninstall-WSL {
    param(
        [Parameter(Mandatory)][string]$InstanceName
    )

    $InstanceName = ($InstanceName -replace '[\u0000-\u001F\u007F]', '').Trim()
    $confirm = Read-Host "Are you sure you want to uninstall '$InstanceName'? Type 'YES' to confirm"
    if ($confirm -ne 'YES') { Write-Host "Cancelled"; return }

    & wsl.exe --terminate $InstanceName 2>$null
    & wsl.exe --unregister $InstanceName 2>$null

    Write-Host "WSL instance '$InstanceName' removed."
    Read-Host "Press Enter to continue..."
}

# =========================
# Menus
# =========================

function Menu-Install {
    $items = [ordered]@{}
    for ($i = 0; $i -lt $distros.Count; $i++) {
        $items.Add($i, $distros[$i].Name)
    }

    $keys = @($items.Keys)
    $choice = Select-InteractiveItem -Title "Install Linux distribution" -Items $items -Footer (Get-StatusFooter) -KeyList $keys

    if ($null -eq $choice) { return }
    Manage-Distrib -Index $choice
}

function Menu-refreshTerminal {
    $instances = (wsl.exe --list --quiet 2>$null) -replace '\x00', '' |
                 ForEach-Object { $_.Trim() } |
                 Where-Object { $_ }
    if (-not $instances) { Write-Host "No WSL instances found."; Start-Sleep 2; return }

    $items = [ordered]@{}
    foreach ($name in $instances) { $items[$name] = $name }

    $instance = Select-InteractiveItem -Title "Refresh Terminal Profile for WSL Instance" -Items $items -Footer (Get-StatusFooter)
    if ($null -eq $instance) { return }

    $defaultTheme = 'One Half Dark'
    $userTheme = Read-Host "Choose a terminal theme [$defaultTheme]"
    $themeToUse = if ([string]::IsNullOrWhiteSpace($userTheme)) { $defaultTheme } else { $userTheme }


    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $altDir = Join-Path $scriptDir 'windows\manageDistrib'
    $terminalScriptPath = Join-Path $altDir 'terminalSettings.ps1'

    if (-not (Test-Path $terminalScriptPath)) {
        Write-Warning "Terminal settings script not found."
        Start-Sleep 7
        return
    }

    try {
        & $terminalScriptPath -profileName $instance -colorScheme $themeToUse -ErrorAction Stop
        Write-Host "Terminal profile refreshed successfully"
    }
    catch {
        Write-Warning "Terminal profile refresh failed: $_"
        Start-Sleep 7
    }
}

function Menu-Uninstall {
    $instances = (wsl.exe --list --quiet 2>$null) -replace '\x00', '' |
                 ForEach-Object { $_.Trim() } |
                 Where-Object { $_ }
    if (-not $instances) { Write-Host "No WSL instances found."; Start-Sleep 2; return }

    $items = [ordered]@{}
    foreach ($name in $instances) { $items[$name] = $name }

    $instance = Select-InteractiveItem -Title "Uninstall WSL distribution" -Items $items -Footer (Get-StatusFooter)
    if ($null -eq $instance) { return }

    Uninstall-WSL -InstanceName $instance
}

function Menu-LocalSettings {
    $base = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
    $dir  = Join-Path $base 'windows\localSettings'

    if (-not (Test-Path $dir)) { Write-Host "Local settings directory not found: $dir"; Start-Sleep 2; return }

    $files = Get-ChildItem $dir -Filter '*.ps1' -File | Where-Object { -not $_.Name.StartsWith('_') }
    if (-not $files) { Write-Host "No local settings scripts found."; Start-Sleep 2; return }

    $items = [ordered]@{}
    foreach ($f in $files) {
        $name = [IO.Path]::GetFileNameWithoutExtension($f.Name) -replace '[-_]', ' '
        $items[$f.FullName] = (Get-Culture).TextInfo.ToTitleCase($name)
    }

    $script = Select-InteractiveItem -Title "Local Windows settings" -Items $items -Footer (Get-StatusFooter)
    if ($null -eq $script) { return }

    try { & $script } catch { Write-Warning "Local settings script failed: $_" }
    Read-Host "Press Enter to return to menu..."
}

# =========================
# Main Loop
# =========================

function Show-Menu {
    while ($true) {
        $items = [ordered]@{
            Install   = "Install Linux distribution"
            Refresh   = "Refresh Terminal Profile"
            Uninstall = "Uninstall WSL distribution"
            Local     = "Local Windows settings"
            Exit      = "Exit"
        }

        $action = Select-InteractiveItem -Title "WSL Workstation Setup" -Items $items -Footer (Get-StatusFooter) -KeyList @('Install', 'Refresh', 'Uninstall', 'Local', 'Exit')
        if ($null -eq $action -or $action -eq 'Exit') { return }
        switch ($action) {
            'Install'   { Menu-Install }
            'Refresh'   { Menu-refreshTerminal }
            'Uninstall' { Menu-Uninstall }
            'Local'     { Menu-LocalSettings }
        }
    }
}

# =========================
# Start
# =========================

Show-Menu
