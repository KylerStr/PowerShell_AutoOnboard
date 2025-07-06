<#
### This script is the parent script for PSAO.
### This script will handle all script executions.
#>
# Import module for PSAO
Import-Module -Name "C:\Program Files\PSAO\Modules\PSAOModule.psm1" -Force
# First, verify the configuration file exists.
$ConfigFilePath = "C:\Program Files\PSAO\Assets\Configuration.json"
if (-Not (Test-Path -Path $ConfigFilePath)) {
    New-PSAOSystemLog -Message "Configuration file not found at $ConfigFilePath. Please ensure the configuration file exists." -LogLevel "Error"
    exit 1
}
# Load the configuration file
$PSAOConfiguration = Get-Content -Path $ConfigFilePath | ConvertFrom-Json
# Verify connection to SQL Server
