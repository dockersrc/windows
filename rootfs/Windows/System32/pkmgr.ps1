# PowerShell Package Manager Wrapper
# Supports winget, chocolatey, and can be extended
param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "",
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Packages
)

$ErrorActionPreference = 'Stop'

# Detect package manager
$pkgMgr = $null
$installCmd = $null
$updateCmd = $null
$cleanCmd = $null

if (Get-Command winget -ErrorAction SilentlyContinue) {
    $pkgMgr = "winget"
    $installCmd = { param($pkg) & winget install --id $pkg --accept-source-agreements --accept-package-agreements --silent }
    $updateCmd = { & winget upgrade --all --accept-source-agreements --accept-package-agreements --silent }
    $cleanCmd = { Write-Host "Winget cache management" }
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    $pkgMgr = "chocolatey"
    $installCmd = { param($pkg) & choco install $pkg -y }
    $updateCmd = { & choco upgrade all -y }
    $cleanCmd = { & choco cache clean }
} else {
    Write-Error "No package manager found. Please install winget or chocolatey."
    exit 1
}

Write-Host "Using package manager: $pkgMgr"

# Load config if exists
$configPath = "C:\config\pkmgr\settings.ps1"
if (Test-Path $configPath) {
    . $configPath
}

# Handle commands
switch ($Action.ToLower()) {
    "install" {
        if (-not $Packages -or $Packages.Count -eq 0) {
            Write-Warning "No packages specified"
            exit 0
        }
        
        foreach ($pkg in $Packages) {
            if ($pkg.Trim() -ne "") {
                Write-Host "Installing package: $pkg"
                try {
                    & $installCmd $pkg
                } catch {
                    Write-Error "Failed to install $pkg : $_"
                }
            }
        }
    }
    
    "update" {
        Write-Host "Updating all packages"
        & $updateCmd
    }
    
    "upgrade" {
        Write-Host "Upgrading all packages"
        & $updateCmd
    }
    
    "clean" {
        Write-Host "Cleaning package cache"
        & $cleanCmd
        
        # Clean Windows temp
        Remove-Item -Path 'C:\Windows\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$env:USERNAME\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    "version" {
        if ($pkgMgr -eq "winget") {
            & winget --version
        } elseif ($pkgMgr -eq "chocolatey") {
            & choco --version
        }
    }
    
    default {
        Write-Host "pkmgr - Package Manager Wrapper for Windows Containers"
        Write-Host ""
        Write-Host "Usage: pkmgr <action> [packages...]"
        Write-Host ""
        Write-Host "Actions:"
        Write-Host "  install <pkg>   - Install package(s)"
        Write-Host "  update          - Update all packages"
        Write-Host "  upgrade         - Upgrade all packages"
        Write-Host "  clean           - Clean package cache"
        Write-Host "  version         - Show package manager version"
        Write-Host ""
        Write-Host "Current package manager: $pkgMgr"
    }
}
