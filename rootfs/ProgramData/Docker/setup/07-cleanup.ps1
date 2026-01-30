# PowerShell script for Windows container cleanup
# @Version: 202601231310-git
# @Author: CasjaysDev
# @Contact: CasjaysDev <docker-admin@casjaysdev.pro>
# @License: MIT
# @Copyright: Copyright 2026 CasjaysDev
# @File: 07-cleanup.ps1
# @Description: Script for cleanup tasks

$ErrorActionPreference = 'Stop'
$exitCode = 0

# Clean Windows temp files
Remove-Item -Path 'C:\Windows\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'C:\Users\*\AppData\Local\Temp\*' -Recurse -Force -ErrorAction SilentlyContinue

# Clean package caches
if (Get-Command winget -ErrorAction SilentlyContinue) {
    # Winget doesn't have explicit cache clean yet
    Write-Host 'Winget cache management'
}

exit $exitCode
