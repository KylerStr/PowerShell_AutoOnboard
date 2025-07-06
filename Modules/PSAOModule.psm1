function New-PSAOSystemLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [string]$LogLevel = 'Info'
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
    $i = 0
    Do {
        $i++
        Try {
            $LogFilePath = "C:\Program Files\PSAO\Logs\PSAOSystem-$i.log"
            If (!(Test-Path -Path $LogFilePath)) {
                New-Item -ItemType File -Path $LogFilePath -Force | Out-Null
            }
            $Timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
            $LogEntry = "$Timestamp [$LogLevel] $Message"
            Try {
                Add-Content -Path $LogFilePath -Value $LogEntry
                Write-Host $Message
                $LogSuccess = $true
            }
            Catch {
                $LogSuccess = $false
            }
        }
        Catch {
            Write-Host "Failed to write to log file: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    While ($LogSuccess -eq $False -and $i -lt 5)
    
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
        Throw 'Could not connect to SQL Server. Please check your connection string and ensure the server is reachable.'
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
        Throw 'Could not connect to SQL Server. Please check your connection string and ensure the server is reachable.'
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
Function New-Password {
    <#
        .SYNOPSIS
        Generates a new random password.
        .Description
        This function generates a new random password with a specified length and complexity.
        .Parameter Length
        The length of the password to generate. Default is 12 characters.
        .Example
        New-Password -Length 16
    #>
    # Define three arrays of words
    $WordArray1 = @('Blue', 'Red', 'Green', 'Yellow', 'Purple', 'Orange', 'Pink', 'Black', 'White', 'Gray', 'Fast', 'Smart', 'Strong', 'Happy')
    $WordArray2 = @('Car', 'House', 'Tree', 'Computer', 'Phone', 'Book', 'Table', 'Chair', 'Lamp', 'Window', 'Keyboard', 'Plane', 'Train', 'Boat', 'Bicycle', 'Motorcycle')
    $WordArray3 = @('Dog', 'Cat', 'Bird', 'Fish', 'Mouse', 'Rabbit', 'Hamster', 'Lizard', 'Snake', 'Frog', 'Turtle', 'Horse', 'Cow', 'Pig', 'Sheep')
    $SymbolArray = @('!', '@', '#', '$', '%', '^', '&', '*',  '?')
    #Now, generate a password using a random selection from each array
    $Password = "$((Get-Random -InputObject $WordArray1))$((Get-Random -InputObject $WordArray2))$((Get-Random -InputObject $WordArray3))$((Get-Random -InputObject $SymbolArray))"
    # Now, choose a random character to replace with leet speak
    #Define array, which contains leet speak mappings. Index 0 is the character to replace, index 1 is the leet speak equivalent
    $LeetMapping = @(
        'a@',
        'e3',
        'i1',
        'o0',
        's$',
        't7'
    )
    #Get a random mapping from the leet speak array
    $Replacement = Get-Random -InputObject $LeetMapping
    # Replace the character in the password with its leet speak equivalent
    $Password = $Password.Replace("$($Replacement[0])", "$($Replacement[1])")
    # Finally, add a random number to the end of the password
    $Password = "$Password$(Get-Random -Minimum 0 -Maximum 100)"
    #Verify the password length is >= 12 characters
    If ($Password.Length -lt 12) {
        $CharsToAdd = 12 - $Password.Length
        For ($i = 0; $i -lt $CharsToAdd; $i++) {
            # Generate a random character
            $RandomChar = [char](Get-Random -Minimum 33 -Maximum 126) 
            $Password += $RandomChar
        }
    }
    # Return the generated password
    Return $Password
}