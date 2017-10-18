<#
    .NOTES 
    Name: Availability Group Refresh
    Author: Rob Sewell 
    Revised:  Brett Reynolds
    
    .DESCRIPTION
    Refresh single or all user database from one AG (or instance) to another AG (Same or Different).
    1) Gets database or databases from load server and backs up to FileShare
    2) Checks target availability group, gets up to 3 replicas.  Checks if DB is in AG already.
    3) For each database, removes database from Availability Group
    4) Restores database to each replica, creates a new database IF does not exist.
    5) Adds databases back to AG.
    
    Notes:  Used powershell 4.0,  Need SQL Management objects on computer (Studio or SDK), SysAdm rights for user running,
            and file share access for user running.

#> 

cls

$LoadServer = "sqlserver-prod.domain.loc" # The Load Server - Server with production database Fully Qualified Name
$LoadServerInstance = "sqlinstance" # The Load Server Instance
$DBName = "databasename" # Database Name (Comman seperate) , IF BLANK WILL TARGET ALL DATABASES IF DBALL = 1
$DBAll = "0"  # IF DBName is BLank and DBAll is 1 - Will Copy All User Databases
$FileShare = '\\sql-utility\scratch\' # Enter FileShare with trailing slash ex: \\fileshare\sql\

 # Set to 1 to Auto set Primary, Secondary, Tri Server Replica info from AG Group
 # Set to 0 to Manually set Primary, Secondary, Tri Server Replica info
$TargetAGLoadServer = "1"

# Target Availability Group Name ex: availability-groupname
$TargetAGName = "availability-groupname"

# FILL IN IF TargetAGLoadServer = 1 
$TargetAGListner = "sqlserver-dev.domain.loc"  # Target Listner Address Fully Qualified Name
$TargetAGInstance = "sqlinstance"  # Target Instance Address

# FILL IN IF TargetAGLoadServer = 0
$PrimaryServer = "" # The Primary Availability Group Server  ex: sql-server.company.loc
$PrimaryServerInstance = ""  # The Primary Availability Group Instance  ex: sqlinstance
$SecondaryServer = "" # The Secondary Availability Group Server
$SecondaryServerInstance = "" # The Secondary Availability Group Instance
$TertiaryServer = ""
$TertiaryServerInstance = ""


function Invoke-Sqlcmd2 { 
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

function Write-Exception {
    Param($exception)
    Write-Host $exception.Message
    While ($exception.InnerException) {
        $exception = $exception.InnerException
        Write-Host $exception.Message
    }
    }

function Test-Access() {
    param([String]$Path)
    $guid = [System.Guid]::NewGuid()
    $access= ""
    try
    {   
        Set-Location -Path HKCU:\
        $filepath = 'filesystem::' + $Path
        if(Test-Path -Path $filepath)
        {
             $access += "Read"
        }
    }
    catch
    {
        #Write-Host $_
    }

    if($access -eq "Read")
    {
        try
        {
            $guid = [System.Guid]::NewGuid()
            [IO.File]::Create($Path+$guid, 1, 'DeleteOnClose') > $null
            $access += "Write"
        }
        catch
        {
            #Write-Host $_
        }
        finally
        {
            Remove-Item $Path$guid -ErrorAction SilentlyContinue
        }
    }

    $access
}

# To Load SQL Server Management Objects into PowerShell
    [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’)  | out-null
    [System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMOExtended’)  | out-null

# Test Path File Share AND Write Access
try
{
    $access = Test-Access $FileShare
    if($access -eq "ReadWrite")
    {
        Write-Host "File Share Access to $FileShare"
    }
    elseif($access -eq "Read")
    {
        Write-Host "File Share Permission Write Error $FileShare" -ForegroundColor Red
        Exit
    }
    else
    {
        Write-Host "File Share Permission Read Error $FileShare" -ForegroundColor Red
        Exit
    }
}
catch
{
    Write-Host $_ -ForegroundColor Red
    Exit
}

# Load Replica info if 1
if($TargetAGLoadServer -eq "1")
{
    if (Test-Connection $TargetAGListner -Count 1 -ea 0 -Quiet)
    { 
       Write-Host "Responded (Target) Object $TargetAGListner"
    }
    else 
    { 
        Write-Exception $_ -ForegroundColor Red
        Write-Host "Unable Get Response (Target) Object $TargetAGListner" -ForegroundColor Red
        Exit
    }

    Try 
    {
        $TargetServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $TargetAGListner\$TargetAGInstance
        if([string]::IsNullOrWhiteSpace($TargetServerObj.InstanceName))
        {
            Write-Host "No Instance found on (Target) Object $TargetAGInstance" -ForegroundColor Red
            Exit
        }

        $TargetServerAG = $TargetServerObj.AvailabilityGroups[$TargetAGName]
        if($TargetServerAG.AvailabilityReplicas.Count -lt 2)
        {
            Write-Host "No Replicas found on (Target) Object $TargetAGListner" -ForegroundColor Red
            Exit
        }

        #Get Primary Server
        #$TargetServerAG.AvailabilityReplicas | Where-Object {$_.Role -eq "Primary"} 
        $TargetServerObj.AvailabilityGroups[$TargetAGName].AvailabilityReplicas |  Where-Object {$_.Role -eq "Primary"} | 
        ForEach-Object {
            $PrimaryServer = $_.Name.Substring(0,$_.Name.IndexOf('\'))
            $PrimaryServerInstance = $_.Name.Substring($_.Name.IndexOf('\')+1)
         }

        if($PrimaryServer -eq "")
        {
            Write-Host "No Primary Replica found on (Target) Object $TargetAGListner" -ForegroundColor Red
            Exit
        }
        else
        {
            Write-Host "Primary Replica found on (Target) Object $TargetAGListner"
        }

        #Get Secondary-Tertieary Servers
        $TargetServerCount = 0
        $TargetServerObj.AvailabilityGroups[$TargetAGName].AvailabilityReplicas |  Where-Object {$_.Role -eq "Secondary"} | 
        ForEach-Object {
            if($TargetServerCount -eq 0)
            {
                $SecondaryServer = $_.Name.Substring(0,$_.Name.IndexOf('\'))
                $SecondaryServerInstance = $_.Name.Substring($_.Name.IndexOf('\')+1)
                $TargetServerCount = $TargetServerCount + 1
            }
            elseif($TargetServerCount -eq 1)
            {
                $TertiaryServer = $_.Name.Substring(0,$_.Name.IndexOf('\'))
                $TertiaryServerInstance = $_.Name.Substring($_.Name.IndexOf('\')+1)
                $TargetServerCount = $TargetServerCount + 1
            }
         }

        if($SecondaryServer -eq "")
        {
            Write-Host "No Secondary Replica found on (Target) Object $TargetAGListner" -ForegroundColor Red
            Exit
        }else
        {
            Write-Host "Secondary Replica found on (Target) Object $TargetAGListner"
        }

        # Show Replication Database Info
        #$TargetServerObj.AvailabilityGroups[$TargetAGName].DatabaseReplicaStates | Select-Object AvailabilityReplicaServerName, AvailabilityDatabaseName, IsLocal, IsSuspended, SuspendReason

    }
    catch
    {
        Write-Exception $_
        Write-Host "Unable Get Replica (Target) Object $TargetAGListner" -ForegroundColor Red
        Exit
    }
}
elseif ($PrimaryServer -eq "")
{ 
    Write-Host "TargetAGLoadServer Not Set, Must Enter Replica Information" -ForegroundColor Red
    Exit
}

# START
$Date = Get-Date -Format ddMMyy

# Path to Availability Database Objects
$MyAgPrimaryPath = "SQLSERVER:\SQL\$PrimaryServer\$PrimaryServerInstance\AvailabilityGroups\$TargetAGName"
$MyAgSecondaryPath = "SQLSERVER:\SQL\$SecondaryServer\$SecondaryServerInstance\AvailabilityGroups\$TargetAGName"
$MyAgTertiaryPath = "SQLSERVER:\SQL\$TertiaryServer\$TertiaryServerInstance\AvailabilityGroups\$TargetAGName"

if($LoadServer -eq "" -or $LoadServerInstance -eq "")
{
    Write-Host "Load server/instance not set, please add load server to get source database(s)." -ForegroundColor Red
    Exit
}

# Check Database Name Exists
if($DBName -eq "" -and $DBAll -eq "0")
{
    Write-Host "Database Name not set and DBAll not set.  Either specify DBName or set DBAll to 1 for copying all user databases." -ForegroundColor Red
    Exit
}
elseif($DBName -eq "" -and $DBAll -eq "1")
{
    #Get List of User Databases and set to $DBName
    Try 
        {
            if (Test-Connection $LoadServer -Count 1 -ea 0 -Quiet)
            { 
               Write-Host "Responded (Target) Object $LoadServer"
            }
            else 
            { 
                Write-Host $_
                Write-Host "Unable Get Response (Target) Object $LoadServer" -ForegroundColor Red
                Exit
            }

            $LoadServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $LoadServer\$LoadServerInstance -warningaction silentlycontinue
            if([string]::IsNullOrWhiteSpace($LoadServerObj.InstanceName))
            {
                Write-Host "No Instance found on (LoadDB) Object $LoadServerInstance" -ForegroundColor Red
                Exit
            }

            # Get User Databases
            $LoadServerDatabases = $LoadServerObj.Databases | Where-Object  {$_.IsSystemObject -eq $false}
            $LoadServerDatabases | ForEach{
            if($DBName -eq "")
                {
                    $DBName = $_.Name
                }
                else
                {
                    $DBName = $DBName + "," + $_.Name
                }
            }

            if($DBName -eq "")
            {
                Write-Host "No user databases found on load server." -ForegroundColor Red
                Exit
            }
            else
            {
                Write-Host "Found " $LoadServerDatabases.Count " total databases on load server (" $DBName ")"
            }
        }
        catch
        {
            Write-Host $_
            Write-Host "Unable Get Databases (LoadDB) Object $LoadServer" -ForegroundColor Red
            Exit
        }

}

# FOR Each Database Name Restore on Target
$DBName.Split(",") | ForEach {

$DBNameTarget = $_
$PrimaryServerDBExist = ""
$PrimaryServerDBExistAG = ""
$SecondaryServerDBExist = ""
$SecondaryServerDBExistAG = ""
$TertiaryServerDBExist = ""
$TertiaryServerDBExistAG = ""

if($DBNameTarget -eq "")
{
   Write-Host "Database Name is blank." -ForegroundColor Red
   Exit
}

$LoadDatabaseBackupFile = $FileShare + $DBNameTarget + "_" + $Date + ".bak" # Load database Backup location - Needs access permissions granted
$DatabaseBackupFile = $FileShare + $DBNameTarget + "_" + $Date + ".bak" # database Backup location - Needs access permissions granted
$LogBackupFile = $FileShare + $DBNameTarget + "_" + $Date + ".trn" # database Backup location - Needs access permissions granted

# Check Load Server
if($LoadServer)
{
    Try 
    {
        if (Test-Connection $LoadServer -Count 1 -ea 0 -Quiet)
        { 
           Write-Host "Responded (Target) Object $LoadServer"
        }
        else 
        { 
            Write-Host $_
            Write-Host "Unable Get Response (Target) Object $LoadServer" -ForegroundColor Red
            Exit
        }

        $LoadServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $LoadServer\$LoadServerInstance -warningaction silentlycontinue
        if([string]::IsNullOrWhiteSpace($LoadServerObj.InstanceName))
        {
            Write-Host "No Instance found on (LoadDB) Object $LoadServerInstance" -ForegroundColor Red
            Exit
        }

        # Check Database Exists
        if(($LoadServerObj.Databases | Where-Object  {$_.Name -eq $DBNameTarget} | Select-Object Status))
        {
           Write-Host "Check Database (LoadDB) $LoadServer Passed"
        }
        else
        {
            Write-Host "Check Database (LoadDB) $LoadServer Failed" -ForegroundColor Red
            Exit
        }
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable Check Database (LoadDB) Object $LoadServer" -ForegroundColor Red
        Exit
    }
}
else
{
    Write-Host "Unable Check Server (LoadDB) Object $LoadServer" -ForegroundColor Red
    Exit
}

# Check Database Objects
if($PrimaryServer)
{
    Try 
    {
        
        if (Test-Connection $PrimaryServer -Count 1 -ea 0 -Quiet)
        { 
           Write-Host "Responded (Primary) Object $PrimaryServer"
        }
        else 
        { 
            Write-Host $_
            Write-Host "Unable Get Response (Primary) Object $PrimaryServer" -ForegroundColor Red
            Exit
        }

        $PrimaryServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue
        if([string]::IsNullOrWhiteSpace($PrimaryServerObj.InstanceName))
        {
            Write-Host "No Instance found on (Primary) Object $PrimaryServerInstance" -ForegroundColor Red
            Exit
        }

        # Check Database Exists
        if(($PrimaryServerObj.Databases | Where-Object  {$_.Name -eq $DBNameTarget} | Select-Object Status))
        {
            $PrimaryServerDBExist = "1"
            Write-Host "Check Database (Primary) $PrimaryServer Passed for $DBNameTarget"

            # Check Database in AG
            $PrimaryServerAG = $PrimaryServerObj.AvailabilityGroups[$TargetAGName]
            ($PrimaryServerAG.AvailabilityDatabases | Where-Object {$_.Name -eq $DBNameTarget} | Select-Object SynchronizationState) | ForEach {
            
                if($_.SynchronizationState -eq "Synchronized")
                {
                    Write-Host "Check Database (Primary) AvailabilityGroup $PrimaryServer Passed for $DBNameTarget"
                    $PrimaryServerDBExistAG = "1"
                }
                elseif($_.SynchronizationState -eq "NotSynchronizing")
                {
                    Write-Host "Database SynchronizationState Error (Primary) Object $PrimaryServer for $DBNameTarget" -ForegroundColor Red
                    Exit
                }
            }

            if($PrimaryServerDBExistAG -eq "0")
            {
                Write-Host "Check Database (Primary) AvailabilityGroup $PrimaryServer Not Exist for $DBNameTarget" -ForegroundColor Yellow
            }
        }
        else
        {
            Write-Host "Check Database (Primary) $PrimaryServer Not Exist for $DBNameTarget" -ForegroundColor Yellow
        }
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable Check Database Object (Primary) $PrimaryServer for $DBNameTarget" -ForegroundColor Red
        Exit
    }
}

if($SecondaryServer)
{
    Try 
    {
        if (Test-Connection $SecondaryServer -Count 1 -ea 0 -Quiet)
        { 
           Write-Host "Responded (Secondary) Object $SecondaryServer"
        }
        else 
        { 
            Write-Host $_
            Write-Host "Unable Get Response (Secondary) Object $SecondaryServer" -ForegroundColor Red
            Exit
        }

        $SecondaryServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $SecondaryServer\$SecondaryServerInstance -warningaction silentlycontinue
        if([string]::IsNullOrWhiteSpace($SecondaryServerObj.InstanceName))
        {
            Write-Host "No Instance found on (Secondary) Object $SecondaryServerInstance" -ForegroundColor Red
            Exit
        }

        # Check Database Exists
        if(($SecondaryServerObj.Databases | Where-Object  {$_.Name -eq $DBNameTarget} | Select-Object Status))
        {
            $SecondaryServerDBExist = "1"
            Write-Host "Check Database (Secondary) $SecondaryServer Passed for $DBNameTarget"

            # Check Database in AG
            $SecondaryServerAG = $SecondaryServerObj.AvailabilityGroups[$TargetAGName]
            ($SecondaryServerAG.AvailabilityDatabases | Where-Object {$_.Name -eq $DBNameTarget} | Select-Object SynchronizationState) | ForEach {
            
                if($_.SynchronizationState -eq "Synchronized")
                {
                    Write-Host "Check Database (Secondary) AvailabilityGroup $SecondaryServer Passed for $DBNameTarget"
                    $SecondaryServerDBExistAG = "1"
                }
                elseif($_.SynchronizationState -eq "NotSynchronizing")
                {
                    Write-Host "Database SynchronizationState Error (Secondary) Object $SecondaryServer for $DBNameTarget" -ForegroundColor Red
                    Exit
                }
            }

            if($SecondaryServerDBExistAG -eq "0")
            {
                Write-Host "Check Database (Secondary) AvailabilityGroup $SecondaryServer Not Exist for $DBNameTarget" -ForegroundColor Yellow
            }
        }
        else
        {
            Write-Host "Check Database (Secondary) $SecondaryServer Not Exist for $DBNameTarget" -ForegroundColor Yellow
        }
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable Check Database (Secondary) Object $SecondaryServer for $DBNameTarget" -ForegroundColor Red
        Exit
    }
}

if($TertiaryServer)
{
    Try 
    {
        if (Test-Connection $TertiaryServer -Count 1 -ea 0 -Quiet)
        { 
           Write-Host "Responded (Tertiary) Object $TertiaryServer"
        }
        else 
        { 
            Write-Host $_
            Write-Host "Unable Get Response (Tertiary) Object $TertiaryServer" -ForegroundColor Red
            Exit
        }

        $TertiaryServerObj = New-Object Microsoft.SQLServer.Management.SMO.Server $TertiaryServer\$TertiaryServerInstance -warningaction silentlycontinue
        if([string]::IsNullOrWhiteSpace($TertiaryServerObj.InstanceName))
        {
            Write-Host "No Instance found on (Tertiary) Object $TertiaryServerInstance" -ForegroundColor Red
            Exit
        }

        # Check Database Exists
        if(($TertiaryServerObj.Databases | Where-Object  {$_.Name -eq $DBNameTarget} | Select-Object Status))
        {
            $TertiaryServerDBExist = "1"
            Write-Host "Check Database (Tertiary) $TertiaryServer Passed for $DBNameTarget"

            # Check Database in AG
            $TertiaryServerAG = $TertiaryServerObj.AvailabilityGroups[$TargetAGName]
            ($TertiaryServerAG.AvailabilityDatabases | Where-Object {$_.Name -eq $DBNameTarget} | Select-Object SynchronizationState) | ForEach {
            
                if($_.SynchronizationState -eq "Synchronized")
                {
                    Write-Host "Check Database (Tertiary) AvailabilityGroup $TertiaryServer Passed for $DBNameTarget"
                    $TertiaryServerDBExistAG = "1"
                }
                elseif($_.SynchronizationState -eq "NotSynchronizing")
                {
                    Write-Host "Database SynchronizationState Error (Tertiary) Object $TertiaryServer for $DBNameTarget" -ForegroundColor Red
                    Exit
                }
            }

            if($TertiaryServerDBExistAG -eq "0")
            {
                Write-Host "Check Database (Tertiary) AvailabilityGroup $TertiaryServer Not Exist for $DBNameTarget" -ForegroundColor Yellow
            }
        }
        else
        {
            Write-Host "Check Database (Tertiary) $TertiaryServer Failed for $DBNameTarget" -ForegroundColor Yellow
        }
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable Check Database (Tertiary) Object $TertiaryServer for $DBNameTarget" -ForegroundColor Red
        Exit
    }
}

$StartDate = Get-Date
Write-Host "Start refresh $DBNameTarget on $PrimaryServer $SecondaryServer $TertiaryServer on AG $AGName Time Script Started $StartDate" -ForegroundColor Green

cd c:

# Remove old backups
If(Test-Path $LoadDatabaseBackupFile)
{
    Remove-Item -Path $LoadDatabaseBackupFile -Force 
    Write-Host "LoadDatabaseBackupFile Files removed"
}
If(Test-Path $DatabaseBackupFile)
{
    Remove-Item -Path $DatabaseBackupFile 
    Write-Host "DatabaseBackupFile Files removed"
}
If(Test-Path $LogBackupFile ) 
{
    Remove-Item -Path $LogBackupFile 
    Write-Host "LogBackupFile Files removed"
}

# Remove Replica Databases from Availability Group
if($SecondaryServerDBExistAG -eq "1")
{
    Try 
    {
        Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$SecondaryServer\$SecondaryServerInstance\AvailabilityGroups\$TargetAGName\AvailabilityDatabases\$DBNameTarget -warningaction silentlycontinue
        Start-Sleep -s 3
        Write-Host "Secondary Removed from Availability Group" -ForegroundColor Green
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable to Remove Secondary from Availability Group $SecondaryServer" -ForegroundColor Red
        Exit
    }
}

if($TertiaryServerDBExistAG -eq "1")
{
    Try 
    {
        # Remove Tertiary Replica Database from Availability Group to enable restore
        Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$TertiaryServer\$TertiaryServerInstance\AvailabilityGroups\$TargetAGName\AvailabilityDatabases\$DBNameTarget  -warningaction silentlycontinue
        Start-Sleep -s 3
        Write-Host "Tertiary Removed from Availability Group" -ForegroundColor Green
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable to Remove Tertiary from Availability Group $TertiaryServer" -ForegroundColor Red
        Exit
    }
}

if($PrimaryServerDBExistAG -eq "1")
{
    Try 
    {
        # Remove Primary Replica Database from Availability Group to enable restore
        Remove-SqlAvailabilityDatabase -Path SQLSERVER:\SQL\$PrimaryServer\$PrimaryServerInstance\AvailabilityGroups\$TargetAGName\AvailabilityDatabases\$DBNameTarget  -warningaction silentlycontinue
        Start-Sleep -s 3
        Write-Host "Primary Removed from Availability Group" -ForegroundColor Green
    }
    catch
    {
        Write-Host $_
        Write-Host "Unable to Remove Primary from Availability Group $PrimaryServer" -ForegroundColor Red
        Exit
    }
}


# Backup Load Database
Try 
{
    Backup-SqlDatabase -Database $DBNameTarget -BackupFile $LoadDatabaseBackupFile -ServerInstance $LoadServer\$LoadServerInstance -warningaction silentlycontinue
    Write-Host "Backup Load Server Database for $DBNameTarget" -ForegroundColor Green
}
catch
{
   Write-Exception $_
   Write-Host "Unable to Backup Load Server Database $LoadServer for $DBNameTarget" -ForegroundColor Red
   Exit
}

# Restore Database to Primary
Try 
{
    if($PrimaryServer)
    {
        # Remove connections to database for Restore
        if($PrimaryServerDBExist)
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue
            $srv.KillAllProcesses($DBNameTarget)
            # Restore Primary Replica Database from Load Database
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LoadDatabaseBackupFile  -ServerInstance $PrimaryServer\$PrimaryServerInstance -ReplaceDatabase -warningaction silentlycontinue
            Write-Host "Primary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
        else
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue
            $dataFolder = $srv.Settings.DefaultFile;
            $logFolder = $srv.Settings.DefaultLog;
            
            if ($dataFolder.Length -eq 0 -or $logFolder.Length -eq 0)
            {
                Write-Host "Primary Database Log - Data Folder Default Path Empty" -ForegroundColor Red
                EXIT
            }

            $backupDeviceItem = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem $LoadDatabaseBackupFile, File;

            $restore = new-object 'Microsoft.SqlServer.Management.Smo.Restore';
            $restore.Database = $DBNameTarget;
            $restore.Devices.Add($backupDeviceItem);

            $dataFileNumber = 0;
            foreach ($file in $restore.ReadFileList($srv)) 
            {
                $relocateFile = new-object 'Microsoft.SqlServer.Management.Smo.RelocateFile';
                $relocateFile.LogicalFileName = $file.LogicalName;

                if ($file.Type -eq 'D'){
                    if($dataFileNumber -ge 1)
                    {
                        $suffix = "_$dataFileNumber";
                    }
                    else
                    {
                        $suffix = $null;
                    }

                    $relocateFile.PhysicalFileName = "$dataFolder$DBNameTarget$suffix.mdf";
                    $dataFileNumber ++;
                }
                else 
                {
                    $relocateFile.PhysicalFileName = "$logFolder$DBNameTarget.ldf";
                }

                $restore.RelocateFiles.Add($relocateFile) | out-null;
            }

            #$restore.SqlRestore($srv);
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LoadDatabaseBackupFile  -ServerInstance $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue -RelocateFile $restore.RelocateFiles
            Write-Host "Primary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
        
        # Backup Primary Database
        Backup-SqlDatabase -Database $DBNameTarget -BackupFile $DatabaseBackupFile -ServerInstance $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue
        Backup-SqlDatabase -Database $DBNameTarget -BackupFile $LogBackupFile -ServerInstance $PrimaryServer\$PrimaryServerInstance -BackupAction 'Log' -warningaction silentlycontinue
        Write-Host "Primary Database/Log Backed Up for $DBNameTarget" -ForegroundColor Green
    }
}
catch
{
    Write-Host $_
    Write-Host "Unable to Load Database Backed up $LoadServer for $DBNameTarget" -ForegroundColor Red
    Exit
}

# Restore Database to Secondary
Try 
{
    if($SecondaryServer)
    {
        if($SecondaryServerDBExist)
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SecondaryServer\$SecondaryServerInstance -warningaction silentlycontinue
            $srv.KillAllProcesses($DBNameTarget)
            # Restore Tertiary Replica Database 
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $DatabaseBackupFile -ServerInstance $SecondaryServer\$SecondaryServerInstance -NoRecovery -ReplaceDatabase -warningaction silentlycontinue
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LogBackupFile -ServerInstance $SecondaryServer\$SecondaryServerInstance -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase -warningaction silentlycontinue
            Write-Host "Secondary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
        else
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $SecondaryServer\$SecondaryServerInstance -warningaction silentlycontinue
            $dataFolder = $srv.Settings.DefaultFile;
            $logFolder = $srv.Settings.DefaultLog;
            
            if ($dataFolder.Length -eq 0 -or $logFolder.Length -eq 0)
            {
                Write-Host "Secondary Database Log - Data Folder Default Path Empty" -ForegroundColor Red
                EXIT
            }

            $backupDeviceItem = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem $DatabaseBackupFile, File;

            $restore = new-object 'Microsoft.SqlServer.Management.Smo.Restore';
            $restore.Database = $DBNameTarget;
            $restore.Devices.Add($backupDeviceItem);
            
            $dataFileNumber = 0;
            foreach ($file in $restore.ReadFileList($srv)) 
            {
                $relocateFile = new-object 'Microsoft.SqlServer.Management.Smo.RelocateFile';
                $relocateFile.LogicalFileName = $file.LogicalName;

                if ($file.Type -eq 'D'){
                    if($dataFileNumber -ge 1)
                    {
                        $suffix = "_$dataFileNumber";
                    }
                    else
                    {
                        $suffix = $null;
                    }

                    $relocateFile.PhysicalFileName = "$dataFolder$DBNameTarget$suffix.mdf";

                    $dataFileNumber ++;
                }
                else 
                {
                    $relocateFile.PhysicalFileName = "$logFolder$DBNameTarget.ldf";
                }

                $restore.RelocateFiles.Add($relocateFile) | out-null;
            }
            #$restore.NoRecovery = $TRUE
            #$restore.SqlRestore($srv)
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $DatabaseBackupFile -ServerInstance $SecondaryServer\$SecondaryServerInstance -NoRecovery -RelocateFile $restore.RelocateFiles -warningaction silentlycontinue
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LogBackupFile -ServerInstance $SecondaryServer\$SecondaryServerInstance -RestoreAction 'Log' -NoRecovery -ReplaceDatabase -RelocateFile $restore.RelocateFiles -warningaction silentlycontinue
            Write-Host "Secondary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
    }
}
catch
{
   Write-Host $_
   Write-Host "Unable to Load Database Backed up $SecondaryServer for $DBNameTarget" -ForegroundColor Red
   Exit
}

# Restore Database to Tertiary
Try 
{
    if($TertiaryServer)
    {
        if($TertiaryServerDBExist)
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $TertiaryServer\$TertiaryServerInstance -warningaction silentlycontinue
            $srv.KillAllProcesses($DBNameTarget)
            # Restore Tertiary Replica Database 
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $DatabaseBackupFile -ServerInstance $TertiaryServer\$TertiaryServerInstance -NoRecovery -ReplaceDatabase -warningaction silentlycontinue
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LogBackupFile -ServerInstance $TertiaryServer\$TertiaryServerInstance -RestoreAction 'Log' -NoRecovery  -ReplaceDatabase -warningaction silentlycontinue
            Write-Host "Tertiary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
        else
        {
            $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $TertiaryServer\$TertiaryServerInstance -warningaction silentlycontinue
            $dataFolder = $srv.Settings.DefaultFile;
            $logFolder = $srv.Settings.DefaultLog;
            
            if ($dataFolder.Length -eq 0 -or $logFolder.Length -eq 0)
            {
                Write-Host "Tertiary Database Log - Data Folder Default Path Empty" -ForegroundColor Red
                EXIT
            }

            $backupDeviceItem = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem $DatabaseBackupFile, File;

            $restore = new-object 'Microsoft.SqlServer.Management.Smo.Restore';
            $restore.Database = $DBNameTarget;
            $restore.Devices.Add($backupDeviceItem);

            $dataFileNumber = 0;
            foreach ($file in $restore.ReadFileList($srv)) 
            {
                $relocateFile = new-object 'Microsoft.SqlServer.Management.Smo.RelocateFile';
                $relocateFile.LogicalFileName = $file.LogicalName;

                if ($file.Type -eq 'D'){
                    if($dataFileNumber -ge 1)
                    {
                        $suffix = "_$dataFileNumber";
                    }
                    else
                    {
                        $suffix = $null;
                    }

                    $relocateFile.PhysicalFileName = "$dataFolder$DBNameTarget$suffix.mdf";

                    $dataFileNumber ++;
                }
                else 
                {
                    $relocateFile.PhysicalFileName = "$logFolder$DBNameTarget.ldf";
                }

                $restore.RelocateFiles.Add($relocateFile) | out-null;
            }   
            #$restore.NoRecovery = $TRUE
            #$restore.SqlRestore($srv);
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $DatabaseBackupFile -ServerInstance $TertiaryServer\$TertiaryServerInstance -NoRecovery -RelocateFile $restore.RelocateFiles -warningaction silentlycontinue
            Restore-SqlDatabase -Database $DBNameTarget -BackupFile $LogBackupFile -ServerInstance $TertiaryServer\$TertiaryServerInstance -RestoreAction 'Log' -NoRecovery -ReplaceDatabase -RelocateFile $restore.RelocateFiles -warningaction silentlycontinue
            Write-Host "Tertiary Database Restored for $DBNameTarget" -ForegroundColor Green
        }
    }
}
catch
{
   Write-Exception $_
   Write-Host "Unable to Load Database Backed up $TertiaryServer for $DBNameTarget" -ForegroundColor Red
   Exit
}

# Add database back into Availability Group
Try 
{
    if($PrimaryServer) {Add-SqlAvailabilityDatabase -Path $MyAgPrimaryPath -Database $DBNameTarget -warningaction silentlycontinue }
    if($SecondaryServer) {Add-SqlAvailabilityDatabase -Path $MyAgSecondaryPath -Database $DBNameTarget -warningaction silentlycontinue }
    if($TertiaryServer) {Add-SqlAvailabilityDatabase -Path $MyAgTertiaryPath -Database $DBNameTarget -warningaction silentlycontinue }
    Write-Host "Add Database to Availability Group " -ForegroundColor Green
}
catch
{
   Write-Exception $_
   Write-Host "Unable Add Database to Availability Group"
   Exit
}

}

# Check Availability Group Status
 $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $PrimaryServer\$PrimaryServerInstance -warningaction silentlycontinue
    $AG = $srv.AvailabilityGroups[$TargetAGName]
    $AG.DatabaseReplicaStates|ft -AutoSize

    $EndDate = Get-Date
    $Time = $EndDate - $StartDate
Write-Host "Results of Script to refresh $DBName on $PrimaryServer , $SecondaryServer , $TertiaryServer
on AG $TargetAGName Time Script ended at $EndDate and took $Time" -ForegroundColor Green
