Function Get-PSAOSQLTable {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$TableName
    )
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