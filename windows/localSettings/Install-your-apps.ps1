# MENU: true
# TITLE: Install Your Apps
# DESCRIPTION: Installs common Windows applications via winget

# -----------------------------
# Configuration
# -----------------------------
$apps = @(
    "JAMSoftware.TreeSize.Free",
    "Watfaq.PowerSession",
    "Discord.Discord",
    "OpenWhisperSystems.Signal",
    "Balena.Etcher"
)

$maxRetries = 2
$logDir = Join-Path $PSScriptRoot "logs"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = Join-Path $logDir "install-apps_$timestamp.log"

# -----------------------------
# Logging helper
# -----------------------------
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $Level, $Message
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

# -----------------------------
# Pre-flight checks
# -----------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget is not available on this system."
    return
}

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Write-Log "Starting application installation run"
Write-Log "Log file: $logFile"

# -----------------------------
# Check winget sources
# -----------------------------
Write-Log "Checking winget sources..."
winget source list 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Log "winget source list failed, attempting source update" "WARN"
    winget source update | Out-Null

    winget source list 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "winget sources are broken. Aborting." "ERROR"
        return
    }
}

Write-Log "winget sources OK"

# -----------------------------
# Show plan & confirm
# -----------------------------
Write-Host "`nThe following apps will be installed:`n"
$apps | ForEach-Object { Write-Host " - $_" }

$confirm = Read-Host "`nIs it ok for you? Type 'YES' to confirm"
if ($confirm.ToUpper() -ne 'YES') {
    Write-Log "User cancelled installation"
    return
}

# -----------------------------
# Install loop
# -----------------------------
foreach ($app in $apps) {

    Write-Log "Checking if $app is already installed..."

    $installed = winget list --exact --id $app 2>$null |
                 Select-String -SimpleMatch $app

    if ($installed) {
        Write-Log "Skipping $app (already installed)"
        continue
    }

    $attempt = 0
    $success = $false

    while (-not $success -and $attempt -le $maxRetries) {
        $attempt++

        Write-Log "Installing $app (attempt $attempt of $($maxRetries + 1))"

        winget install `
            -e `
            -h `
            --accept-source-agreements `
            --accept-package-agreements `
            --id $app

        if ($LASTEXITCODE -eq 0) {
            Write-Log "SUCCESS: $app installed"
            $success = $true
        }
        else {
            Write-Log "FAILED: $app install attempt $attempt" "WARN"

            if ($attempt -le $maxRetries) {
                Write-Log "Retrying $app..."
                Start-Sleep -Seconds 3
            }
        }
    }

    if (-not $success) {
        Write-Log "ERROR: $app failed after $($maxRetries + 1) attempts" "ERROR"
    }
}

Write-Log "Installation run completed"
Write-Host "`nAll done!"
