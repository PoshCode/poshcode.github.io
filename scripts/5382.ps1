<# 
.NOTES 
    Name: Refresh Mirrored Database
    Author: Rob Sewell  http://sqldbawithabeard.com
    Requires: Invoke-SQLCMD2 (included)
    Version History: 
                    1.2 22/08/2014 
.SYNOPSIS 
    Refreshes a mirrored database
.DESCRIPTION 
    This script will refresh a mirrored database, recreate mirroring and chekc status of mirroring. 
    Further details on the website
    Requires the variables at the top of the script to be filled in
    IMPORTANT - Orpahaned users are not resolved with this acript without additions. See blog post for options
#>  
# Load Invoke-SQLCMD2


#Load the assemblies the script requires
[void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Management.Common" );
[void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.SmoEnum" );
[void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.Smo" );
[void][reflection.assembly]::LoadWithPartialName( "Microsoft.SqlServer.SmoExtended " );
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") 
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null

# Set up some variables

$PrincipalServer = '' # Enter Principal Server Name
$MirrorServer = '' # Enter Mirror Server Name
$DBName = '' # Enter Database Name
$FileShare = '' # Enter FileShare with trailing slash
$LocationReplace = $FileShare + $DBName + 'Refresh.bak'
$LocationFUll = $FileShare + $DBName + 'formirroring.bak'
$LocationTran = $FileShare + $DBName + 'formirroring.trn'

$PrincipalEndPoint = 'TCP://SERVERNAME:5022' # Change as required
$MirrorEndpoint = 'TCP://SERVERNAME:5022' # Change as required
$WitnessEndpoint = 'TCP://SERVERNAME:5022' # Change as required

$Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
$Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
$File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File

###################### 
<# 
.SYNOPSIS 
Runs a T-SQL script. 
.DESCRIPTION 
Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified 
.INPUTS 
None 
    You cannot pipe objects to Invoke-Sqlcmd2 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
StartTime 
----------- 
2010-08-12 21:21:03.593 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 
.EXAMPLE 
Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 
This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
VERBOSE: hello world 
.NOTES 
Version History 
v1.0   - Chad Miller - Initial release 
v1.1   - Chad Miller - Fixed Issue with connection closing 
v1.2   - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
v1.3   - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
#> 
function Invoke-Sqlcmd2 
{ 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
    [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
    [Parameter(Position=7, Mandatory=$false)] [ValidateScript({test-path $_})] [string]$InputFile, 
    [Parameter(Position=8, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As="DataRow" 
 ) 
 
    if ($InputFile)
    { 
        $filePath = $(resolve-path $InputFile).path 
        $Query =  [System.IO.File]::ReadAllText("$filePath") 
    } 
 
    $conn=new-object System.Data.SqlClient.SQLConnection 
      
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
 &n bsp;  $conn.ConnectionString=$ConnectionString 
     
    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
    if ($PSBoundParameters.Verbose) 
    { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
        $conn.add_InfoMessage($handler) 
    } 
     
    $conn.Open() 
    $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
    $cmd.CommandTimeout=$QueryTimeout 
    $ds=New-Object system.Data.DataSet 
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    [void]$da.fill($ds) 
    $conn.Close() 
    switch ($As) 
    { 
        'DataSet'   { Write-Output ($ds) } 
        'DataTable' { Write-Output ($ds.Tables) } 
        'DataRow'   { Write-Output ($ds.Tables[0]) } 
    } 
 
} #Invoke-Sqlcmd2

# Check for existence of Backup file with correct name
If (!(Test-Path $LocationReplace))
    {
    Write-Output " There is no file called " 
    Write-Output $LocationReplace
    Write-Output "Please correct and re-run"
    break
    }

# Remove Old Backups
if (Test-Path $locationFull)
    {
    Remove-Item $LocationFUll -Force
    }

if (Test-Path $locationTran)
    {
    Remove-Item $LocationTran -Force
    }

# Create Server objects
$Principal = New-Object Microsoft.SQLServer.Management.SMO.Server $PrincipalServer
$Mirror = New-Object Microsoft.SQLServer.Management.Smo.server $MirrorServer

#Create Database Objects
$DatabaseMirror = $Mirror.Databases[$DBName]
$DatabasePrincipal = $Principal.Databases[$DBName]

# If database is on Mirror server fail it over to Principal
if ($DatabasePrincipal.IsAccessible -eq $False)
    {
       $DatabaseMirror.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Failover) 
    }

# remove mirroring

$DatabasePrincipal.ChangeMirroringState([Microsoft.SqlServer.Management.Smo.MirroringOption]::Off)

#Set up Restore using refresh backup


$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
$restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationReplace,$File)|Out-Null
$restore.Database = $DBName
$restore.ReplaceDatabase = $True
$restore.Devices.add($restoredevice)
#Perform Restore
$restore.sqlrestore($PrincipalServer) # if query time < 600 seconds
# $query = $restore.Script($PrincipalServer) # if using Invoke-SQLCMD2
$restore.Devices.Remove($restoredevice)

# Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used

# Set up Full Backup
$Backup = New-Object Microsoft.SqlServer.Management.Smo.Backup
$Backup.Action = $Full
$Backup.BackupSetDescription = "Full Backup of " + $DBName
$Backup.Database = $DatabasePrincipal.Name
$BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationFull,$File)
$Backup.Devices.Add($BackupDevice)
# Perform Backup
$Backup.SqlBackup($PrincipalServer)
# $query = $Backup.Script($PrincipalServer) # if query time < 600 seconds
$Backup.Devices.Remove($BackupDevice)

# Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used

 
#Setup Trans Backup
$Backup = New-Object Microsoft.SqlServer.Management.Smo.Backup|Out-Null
$Full = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
$Tran = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Log
$File = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
$Backup.Action = $Tran
$Backup.BackupSetDescription = "Log Backup of " + $DBName
$Backup.Database = $DBName
$BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran,$File)|Out-Null
$Backup.Devices.Add($BackupDevice)
# Perform Backup
$Backup.SqlBackup($PrincipalServer)
# $query = $Backup.Script($PrincipalServer) # if query time < 600 seconds
$Backup.Devices.Remove($BackupDevice)

# Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used

#Set up Restore of Full Backup on Mirror Server
$restore = New-Object -TypeName Microsoft.SqlServe r.Management.Smo.Restore|Out-Null
$restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationFUll,$File)|Out-Null
$restore.Database = $DBName
$restore.ReplaceDatabase = $True
$restore.NoRecovery = $true
$restore.Devices.add($restoredevice)
$restore.sqlrestore($MirrorServer) # if query time < 600 seconds
# $query = $restore.Script($MirrorServer) # if using Invoke-SQLCMD2
$restore.Devices.Remove($restoredevice)

# Invoke-Sqlcmd2 -ServerInstance $MirrorServer -Database master -Query $query -ConnectionTimeout 0 # comment out if not used


# Set up Restore of Log Backup on Mirror Server
$restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore|Out-Null
$restoredevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($LocationTran,$File)|Out-Null
$restore.Database = $DBName
$restore.ReplaceDatabase = $True
$restore.NoRecovery = $true
$restore.Devices.add($restoredevice)
$restore.sqlrestore($MirrorServer)
$restore.Devices.Remove($restoredevice)

#Recreate Mirroring
$DatabaseMirror.MirroringPartner = $PrincipalEndPoint
$DatabaseMirror.Alter()
$DatabasePrincipal.MirroringPartner = $MirrorEndpoint
$DatabasePrincipal.MirroringWitness = $WitnessEndpoint
$DatabasePrincipal.Alter()

# Resolve Orphaned Users if needed


#Check that correct file and backup date used

$query = "SELECT TOP 20 [rs].[destination_database_name] as 'database', 
[rs].[restore_date] as 'restoredate', 
[bs].[backup_finish_date] as 'backuptime', 
[bmf].[physical_device_name] as 'Filename'
FROM msdb..restorehistory rs
INNER JOIN msdb..backupset bs
ON [rs].[backup_set_id] = [bs].[backup_set_id]
INNER JOIN msdb..backupmediafamily bmf 
ON [bs].[media_set_id] = [bmf].[media_set_id] 
ORDER BY [rs].[restore_date] DESC"

Invoke-Sqlcmd2 -ServerInstance $PrincipalServer -Database msdb -Query $query |Format-Table -AutoSize -Wrap

$DatabasePrincipal | select Name, MirroringStatus, IsAccessible |Format-Table -AutoSize

