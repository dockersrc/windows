# PowerShell entrypoint for Windows container
# @Version: 202601231310-git
# @Author: CasjaysDev
# @Contact: CasjaysDev <docker-admin@casjaysdev.pro>
# @License: WTFPL
# @Copyright: Copyright (c) 2026 Jason Hempstead, Casjays Developments
# @File: entrypoint.ps1
# @Description: Entrypoint file for windows container

param(
    [string]$Command = ""
)

$ErrorActionPreference = 'Stop'
$SERVICE_PID_FILE = "C:\ProgramData\container.pid"
$SERVICE_IS_RUNNING = "no"

# Trap handler for cleanup
trap {
    Write-Host "Container received shutdown signal"
    if ($SERVICE_IS_RUNNING -ne "yes" -and (Test-Path $SERVICE_PID_FILE)) {
        Remove-Item -Path $SERVICE_PID_FILE -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

# Load debug configuration
if (Test-Path "C:\config\.debug") {
    $env:DEBUGGER_OPTIONS = Get-Content "C:\config\.debug" -Raw
} else {
    $env:DEBUGGER_OPTIONS = ""
}

if ($env:DEBUGGER -eq "on" -or (Test-Path "C:\config\.debug")) {
    $VerbosePreference = 'Continue'
    $DebugPreference = 'Continue'
    Write-Host "Debugging enabled"
}

# Function to check service health
function Test-ServiceHealth {
    # Add health check logic here
    # Return $true if healthy, $false otherwise
    return $true
}

# Handle commands
switch ($Command.ToLower()) {
    "healthcheck" {
        if (Test-ServiceHealth) {
            Write-Host "Service is healthy"
            exit 0
        } else {
            Write-Host "Service is unhealthy"
            exit 1
        }
    }
    "version" {
        Write-Host "Windows Container Version: $env:BUILD_VERSION"
        Write-Host "Distro: Windows Server Core $env:DISTRO_VERSION"
        exit 0
    }
    default {
        # Default startup behavior
        Write-Host "Starting Windows container..."
        Write-Host "Hostname: $env:HOSTNAME"
        Write-Host "Timezone: $env:TIMEZONE"
        
        # Set timezone
        try {
            if ($env:TIMEZONE) {
                & tzutil.exe /s $env:TIMEZONE
                Write-Host "Timezone set to: $env:TIMEZONE"
            }
        } catch {
            Write-Warning "Failed to set timezone: $_"
        }
        
        # Create PID file
        $PID | Out-File -FilePath $SERVICE_PID_FILE -Encoding ASCII
        $global:SERVICE_IS_RUNNING = "yes"
        
        # Keep container running
        Write-Host "Container started successfully"
        Write-Host "Press Ctrl+C to stop"
        
        # Run any startup commands here
        
        # Keep alive loop
        try {
            while ($true) {
                Start-Sleep -Seconds 60
            }
        } finally {
            # Cleanup
            if (Test-Path $SERVICE_PID_FILE) {
                Remove-Item -Path $SERVICE_PID_FILE -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
