function New-PSAOSystemLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [string]$LogLevel = "Info"
    )
    <#
        .SYNOPSIS
        Creates a new system log entry in the PSAO log.
        .Description
        This function creates a new log entry in the PSAO log with the specified message and log level. The log is stored in a file defined by the PSAOConfiguration variable.
        .Parameter Message
        The message to log.
        .Parameter LogLevel
        The level of the log entry (e.g., Info, Warning, Error). Default is "Info".
        .Example
        New-PSAOLog -Message "This is an informational message."
    #>
    #TODO Make this recursive so it can handle if it fails to write to the log file. It will make a new log file with an interated name.
    Try {
        $LogFilePath = "C:\Program Files\PSAO\Logs\PSAOSystem.log"
        If (!(Test-Path -Path $LogFilePath)) {
            New-Item -ItemType File -Path $LogFilePath -Force | Out-Null
        }
        $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $LogEntry = "$Timestamp [$LogLevel] $Message"
        Add-Content -Path $LogFilePath -Value $LogEntry
    }
    Catch {
        Write-Host "Failed to write to log file: $($_.Exception.Message)" -ForegroundColor Red
    }
    
}
Function Get-PSAOSQLTable {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$TableName
    )
    <#
        .SYNOPSIS
        Retrieves data from a specified SQL table.
        .Description
        This function retrieves data from a specified SQL table. This function connects to the SQL Server using the configuration settings defined in the PSAOConfiguration variable.
        .Parameter TableName
        The name of the SQL table to retrieve data from.
        .Example
        Get-PSAOSQLTable -TableName "Tasks"
    #>
    Try {
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $($PSAOConfiguration.SQLData.ServerName); Database = $($PSAOConfiguration.SQLData.DatabaseName); Integrated Security = True;"
    }
    Catch {
        Throw "Could not connect to SQL Server. Please check your connection string and ensure the server is reachable."
    }
    Try {
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = "Select * from $TableName WHERE CurrentStep != 'Cancelled' OR CurrentStep != 'Successful'"
        $SqlCmd.Connection = $SqlConnection 
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd 
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet) 
        $SqlConnection.Close()
    }
    Catch {
        Throw "Error executing SQL command: $($_.Exception.Message)"
    } 
    Return $DataSet.Tables[0]
}
Function New-PSAOSQLCommand {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$TableName,
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    <#
        .SYNOPSIS
        This function creates a new SQL command for a specified table.
        .Description
        This function creates a new SQL command for a specified table. It connects to the SQL Server using the configuration settings defined in the PSAOConfiguration variable.
        .Parameter TableName
        The name of the SQL table to execute the command against.
        .Parameter Command
        The SQL command to execute.
        .Example
        New-PSAOSQLCommand -TableName "Tasks" -Command "SELECT * FROM Tasks WHERE Status = 'Pending'"
    #>
    Try {
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $($PSAOConfiguration.SQLData.ServerName); Database = $($PSAOConfiguration.SQLData.DatabaseName); Integrated Security = True;"
    }
    Catch {
        Throw "Could not connect to SQL Server. Please check your connection string and ensure the server is reachable."
    }
    Try {
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = "USING $TableName
    $Command"
        $SqlCmd.Connection = $SqlConnection 
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd 
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet) 
        $SqlConnection.Close()
    }
    Catch {
        Throw "Error executing SQL command: $($_.Exception.Message)"
    } 
    Return $DataSet.Tables[0]
}