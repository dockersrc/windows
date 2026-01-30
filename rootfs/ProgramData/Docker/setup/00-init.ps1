# PowerShell script for Windows container initialization
# @Version: 202601231310-git
# @Author: CasjaysDev
# @Contact: CasjaysDev <docker-admin@casjaysdev.pro>
# @License: MIT
# @Copyright: Copyright 2026 CasjaysDev
# @File: 00-init.ps1
# @Description: Script to run init

$ErrorActionPreference = 'Stop'
$exitCode = 0

# Predefined actions - Clear template directories
if (Test-Path 'C:/ProgramData/template-files/data') {
    Get-ChildItem 'C:/ProgramData/template-files/data' -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
if (Test-Path 'C:/ProgramData/template-files/config') {
    Get-ChildItem 'C:/ProgramData/template-files/config' -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
if (Test-Path 'C:/ProgramData/template-files/defaults') {
    Get-ChildItem 'C:/ProgramData/template-files/defaults' -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Main script logic here

exit $exitCode
