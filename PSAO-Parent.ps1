<#
### This script is the parent script for PSAO.
### This script will handle all script executions.
#>
# Import module for PSAO
# First, verify the configuration file exists.
$ConfigFilePath = "C:\Program Files\PSAO\Assets\Configuration.json"
if (-Not (Test-Path -Path $ConfigFilePath)) {
    Write-Host "Configuration file not found at $ConfigFilePath. Please run the installation script first." -ForegroundColor Red
    exit 1
}
