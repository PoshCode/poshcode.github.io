function Query-SQLCETable{
    <#
    .SYNOPSIS
    Given a query statement, a proper dll, and a database file the command will run a query and return a table.

    .DESCRIPTION
    The function connects to a database and runs a SQL SELECT statement. Only tested and worked with Microsoft SQL Server Compact version 4.0. The funtion returns false if it fails.

    .EXAMPLE
    $Table = Query-SQLCETable -Query 'SELECT * FROM table' -DataSource 'C:\site\App_Data\site.sdf'

    The command returns an array with each row being an array memeber and the columns being properties.

    .LINK
    http://erikej.blogspot.com/2011/07/using-powershell-to-manage-sql-server.html
    http://blogs.msdn.com/b/miah/archive/2011/08/08/powershell-and-sql-server-compact-4-0-a-happy-mix.aspx
    http://msdn.microsoft.com/en-us/library/system.data.sqlserverce.sqlcecommand(v=vs.80).aspx
    #>

    [cmdletbinding()]
    param(
        
        #The query you want to run against the database.
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        #The path to the database you want to connect to. Should be a ".sdf" file.
        [Parameter(Mandatory=$true,Position=2)]
        [ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})]
        [Alias('Database')]
        [string]$DataSource,

        #The path to the SQLServerCe assembly. Default is "C:\Program Files\Microsoft SQL Server Compact Edition\v4.0\Desktop\System.Data.SqlServerCe.dll".
        [string]$DLLPath='C:\Program Files\Microsoft SQL Server Compact Edition\v4.0\Desktop\System.Data.SqlServerCe.dll'
    )

    try{
        Test-Path -LiteralPath $DLLPath -PathType Leaf -ErrorAction Stop
    }
    catch{
        Write-Error "Invalid `"System.Data.SqlServerCe.dll`" assembly path because $($Error[0].Exception.Message)."
        return $false
    }

    try{
        Write-Verbose 'Loading Assembly'
        [Reflection.Assembly]::LoadFile($DLLPath) | Out-Null

        $ConnectionString = "Data Source=$DataSource"
        $Connection = New-Object -TypeName "System.Data.SqlServerCe.SqlCeConnection" -ArgumentList $ConnectionString

        Write-Verbose 'Creating the command'
        $Command = New-Object -TypeName "System.Data.SqlServerCe.SqlCeCommand" 
        $Command.CommandType = [System.Data.CommandType]"Text" 
        $Command.CommandText = $Query
        $Command.Connection = $Connection
                
        $datatable = New-Object -TypeName "System.Data.DataTable"

        Write-Verbose 'Getting the data'
        $Connection.Open() 
        $returndatatable = $Command.ExecuteReader()

        $datatable.Load($returndatatable) 
        
        Write-Verbose 'Dispose and close'
        $Command.Dispose()
        $Connection.Close()
        $Connection.Dispose()

        return $datatable
    }
    catch{
        Write-Error "Unable to properly execute query because $($Error[0].Exception.Message)."
        return $false
    }
}
