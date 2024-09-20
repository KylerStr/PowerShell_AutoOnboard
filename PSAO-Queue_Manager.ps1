<#
    Script: PSAO-Queue_Manager.ps1
    Function: Manage the PowerShell Auto Onboard queue
    Developer: Kyler Stratton
#>

#############################
# Initial Configuration Files
#############################
# Import Configuration JSON file
Try {
    $PSAOConfiguration = Get-Content -Path "$($PSScriptRoot)\Assets\Configuration.Json" | ConvertFrom-Json
}
Catch {
    If (!(Test-Path "$($PSScriptRoot)\Assets\Configuration.Json")) {
        Throw "Could not locate configuration.json file; Expected location: $($PSScriptRoot)\Assets\Configuration.Json"
    }
    Elseif (Test-Path "$($PSScriptRoot)\Assets\Configuration.Json") {
        Throw "Found configuration.json file, but could not decode from JSON."
    }
}
#Determine what style of SQL Connection should be used
If ($PSAOConfiguration.SQLData.ConnectionStyle -eq 'Integrated') {
    $SQLConnectionString = "Server = $($PSAOConfiguration.SQLData.ServerName); Database = $($PSAOConfiguration.SQLData.DatabaseName); Integrated Security = True;"
}
Else {
    $SQLConnectionString = "Server = $($PSAOConfiguration.SQLData.ServerName); Database = $($PSAOConfiguration.SQLData.DatabaseName); User ID=$($PSAOConfiguration.SQLData.username); Password= $($PSAOConfiguration.SQLData.Password)"
}
##############################
# Define functions
##############################
#Region Function-Definitions
Function Get-PSAOMainTableData {
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server = $($PSAOConfiguration.SQLData.ServerName); Database = $($PSAOConfiguration.SQLData.DatabaseName); Integrated Security = True;" 
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = "Select * from $($PSAOConfiguration.SQLData.OnboardingTable) WHERE Status != 'Cancelled' OR Status != 'Successful'"
    $SqlCmd.Connection = $SqlConnection 
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd 
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet) 
    $SqlConnection.Close() 

}
#endregion