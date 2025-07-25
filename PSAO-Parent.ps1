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
$SQLConnectionString = "Server=$($PSAOConfiguration.SQLData.ServerName);Database=$($PSAOConfiguration.SQLData.DatabaseName);"
if ($PSAOConfiguration.SQLData.ConnectionStyle -eq 'SQLAuth') {
    $SQLConnectionString += "User Id=$($PSAOConfiguration.SQLData.Username);Password=$($PSAOConfiguration.SQLData.Password);"
} else {
    $SQLConnectionString += "Integrated Security=True;"
}
Try {
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection($SQLConnectionString)
    $SqlConnection.Open()
    $SqlConnection.Close()
    New-PSAOSystemLog -Message "Successfully connected to SQL Server at $($PSAOConfiguration.SQLData.ServerName)." -LogLevel "Info"
} Catch {
    New-PSAOSystemLog -Message "Failed to connect to SQL Server at $($PSAOConfiguration.SQLData.ServerName). Error: $($_.Exception.Message)" -LogLevel "Error"
    exit 1
}
# Check Job table in SQL Server exists
$JobTable = Get-PSAOSQLTable -TableName "Jobs" -whereclause "WHERE CurrentStep != 'Cancelled' OR CurrentStep != 'Successful'"
if ($JobTableExists -eq $null) {
    New-PSAOSystemLog -Message "Job table does not exist or is empty. Please ensure the Jobs table is created and populated." -LogLevel "Error"
    exit 1
} else {
    New-PSAOSystemLog -Message "Job table exists and has data." -LogLevel "Info"
}
New-PSAOSystemLog -Message "Checking for running jobs in the Job table." -LogLevel "Info"
If ($JobTable.Count -ge 1) {
    # Check each job in the Job table, see if its still running
    foreach ($Job in $JobTable) {
        # Check Job status via Get-Job
        $JobStatus = Get-Job -Id $Job.Id
        if ($JobStatus.State -eq 'Running') {
            New-PSAOSystemLog -Message "Job $($Job.Id) is still running." -LogLevel "Info"
        } else {
            New-PSAOSystemLog -Message "Job $($Job.Id) is not running. Marking complete." -LogLevel "Info"
        }
    }
}