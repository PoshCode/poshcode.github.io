<# 

 .Title
 PS-NTDSUTIL Script

 .SYNOPSIS 
    Powershell version of the classic NTDSUTIL utility 
 .DESCRIPTION 
   Critical DS task include relocating NTDS.DIT file, EDB.Log, Creating IFM data, offline Defragmentation and the DS intergrity check
   Most functions operate without NTDSUTIL except CheckDIT. Offline_Defrag and Create_FullIFM

 .NOTES 
    Author  : Winston McMiller 
    Requires: PowerShell Version 1.0 and NTDSUTIL
 .LINK 

#> 
 

[CmdletBinding()]

Param(
  [Parameter(Mandatory=$True,Position=0)]
  [string] $DomainController,
  
  [Parameter(Mandatory=$False,Position=1)]
  [Switch] $Move_NTDS_only,
  [Switch] $Move_DSLog_only,
  [Switch] $Move_NTDS_FULL,
  [Switch] $Offline_Defrag,
  [Switch] $DIT_Report,
  [Switch] $Create_FULL_IFM,
  [Switch] $CheckDIT
      )

      #Function to stop AD and its dependant services
Function StopADDS{
Write-Output "Stopping Active directory Domain Service on $DomainController.... "
Stop-Service NTDS -Force 
}
       #Function to start AD and its dependant services
Function StartADDS{
Write-Output "Starting Active directory Domain Service on $DomainController.... "
Start-Service NTDS -Confirm

#Routine to Confirm Service Status
$DSSRV=(Get-Service NTDS).Status
IF($DSSRV -eq "Running"){
Write-Host "Active Directory Domain Service on $DomainController is $DSSRV" -ForegroundColor Green
}

IF($DSSRV -eq "Stopped"){
Write-Host "Active Directory Domain Service on $DomainController is $DSSRV" -ForegroundColor Red
}
}

#Function to trigger NTDSUTIL's semantic database analysis in non-repair mode
Function CheckDIT{
$NTDSSTATUS =""
Write-Output "Checking NTDS database for errors (semantic database analysis)..."
Write-Host ""
Write-Host "____________________________________________________________" -ForegroundColor Blue
$NTDSdbChecker = ntdsutil "activate instance ntds"  "semantic database analysis" "Go" q "files" "checksum" q q
$NTDSdbChecker
Foreach($line in $NTDSdbChecker){If($line -eq "0 bad checksums."){ $NTDSSTATUS = "Good"}}
Write-Host ""
}

#Function to move NTDS.DIT and make DS-related registry changes
Function MoveDIT{

#User input of new NTDS.DIT path. IF unspecified, script will stop
$NewNTDS_Path= Read-Host "Please enter target path for new NTDS location. EX: D:\Windows\NTDS"
if ($NewNTDS_Path -eq ""){
Write-Host "Target Path unspecified. Cannot continue..." -ForegroundColor Red
Break}

# Extract Target's drive letter from given path
$Newdrive=$NewNTDS_Path.substring(0,2)

# Get the target drive's free space
$freespace=(Get-WmiObject -Class Win32_volume -Filter "Driveletter = '$newdrive'").freespace

# Get the target drive's file format
$FS= (Get-WmiObject -Class Win32_volume -Filter "DriveLetter = '$newdrive'").FileSystem
$NewDit=$NewNTDS_Path + "\ntds.dit"
$NewDitBak=$NewNTDS_Path + "\dsadata.bak"

#Extract NTDS parameters from registry
$NTDSDIT= (get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Database File")
$NTDSPath=(get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
$DITSize=(get-item -Path $NTDSDIT).Length

#Check target disk free space
If($DITSize -le $Freespace){
Write-Host "Available Free space on $NewNTDS_Path = $Freespace - Good" -foregroundColor Green}
Else{ Write-Host "Not enough free space on $NewNTDS_Path = $Freespace " -foregroundColor Red
Break}

#Check target disk format
If($FS -notmatch "NTFS"){
Write-Host "Cannot continue NTDS database move. $newDrive is not a NTFS formatted drive." -foregroundColor Red
Break}

#Check for older NTDS.DIT file
If((get-childitem -Path $NewNTDS_Path -Recurse -Filter "NTDS.DIT").Exists -eq "True"){
Write-Host "Cannot continue. Old NTDS.DIT file exists in $NewNTDS_Path ."
Break}

Write-Host "Moving NTDS database from $NTDSpath to $NewNTDS_Path"

#Set DS registry keys to reflect new path
set-itemproperty -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters" -Name "DSA Database File" -value $NewDit
set-itemproperty -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters" -Name "DSA Working Directory" -value $NewNTDS_Path
set-itemproperty -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters" -Name "Database backup path" -value $NewDitBak

#Move the NTDS.Dit file
Move-Item $NTDSDIT $NewNTDS_Path

If($NewNTDSPath + "\NTDS.DIT"){
Write-Host "NTDS.DIT file sucessfully moved to $NewNTDS_Path" -ForegroundColor Green
CheckDIT

Write-Host "NTDS database operation sucessfully completed!!!" -ForegroundColor Green
Write-Host ""
}
}


#Function to move EDB.Log and make the required DS-related registry changes

Function MoveLogs{

# User input of Target path. Script will stop if omitted

$NewNTDS_LogPath= Read-Host "Please enter target path for new EDB Log location. EX: D:\Windows\NTDS"
if ($NewNTDS_LogPath -eq ""){
Write-Host "Target Path unspecified. Cannot continue..." -ForegroundColor Red
Break}

#Variables

#Extract the Target drive letter from the given path
$NewLogdrive=$NewNTDS_LogPath.substring(0,2)

# Get the target drive's free space
$NewLogfreespace=(Get-WmiObject -Class Win32_volume -Filter "Driveletter = '$newlogdrive'").freespace

#Extract NTDS parameters from registry
$DitLogPath=(get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("Database log files path")
$Log= $DitLogPath + "\EDB.Log"
$LogSize=(get-item -Path $Log).Length

# Get the target drive's file format
$LogFS= (Get-WmiObject -Class Win32_volume -Filter "DriveLetter = '$newlogdrive'").FileSystem

# Check target disk free space
If($LOGSize -le $NewLogfreespace){
Write-Host "Available Free space on $NewNTDS_Path = $NewLogfreespace - Good" -foregroundColor Green}
Else{ Write-Host "Not enough free space on $NewNTDS_logPath = $NewLogfreespace " -foregroundColor Red
Start-Service NTDS -Confirm
Break}

# Check the target drive's file format
If($LogFS -ne "NTFS"){
Write-Host "Cannot continue EDB Log move. $newlogDrive is not a NTFS formatted drive." -foregroundColor Red
Start-Service NTDS -Confirm
Break}

# Check the target path for old EDB.Logs
If((get-childitem -Path $NewNTDS_LogPath -Recurse -Filter "EDB.Log").Exists -eq "True"){
Write-Host "Cannot continue. EDB Logs already exists."
Break}

Write-Host "Moving EDB Logs from $DitLogPath to $NewNTDS_LogPath"
set-itemproperty -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters" -Name "Database log files path" -value $NewNTDS_LogPath
Move-Item $Log $NewNTDS_LogPath
Get-ChildItem -Path C:\ntds -Filter "*EDB*" |Remove-item
Write-Host ""
If((get-childitem -Path $NewNTDS_LogPath -Recurse -Filter "EDB.LOG").Exists -eq "True"){
Write-Host "EDB Log move operation sucessfully completed!!!" -ForegroundColor Green
Write-Host ""
}
}

# Scans the registry for NTDS parameters. Very useful in confirm NTDS changes
Function Dit_Report{
$NTDSDIT=(get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Database File")
$DITSize=(get-item -Path $NTDSDIT).Length
$DitStats=Get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters"
$DitStats
Write-Host "                               Present NTDS DB Size                             : $DitSize"
}

#Performs AD Offline Deframentation using NTDSUtil

Function Offline_Defrag{

# User Input of Temp path. Will default to C:\temp if omitted
$TempPath= Read-Host "Please enter Temp path for NTDS.Dit file defragmentation process or Press ENTER for Default= C:\Temp"
if ($TempPath -eq ""){$TempPath="C:\temp"}

#Varibles

$Tempdrive=$TempPath.substring(0,2)
$Tempfreespace=(Get-WmiObject -Class Win32_volume -Filter "Driveletter = '$Tempdrive'").freespace
$NTDSDIT= (get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Database File")
$DITSize=(get-item -Path $NTDSDIT).Length


If($DITSize -ge $Tempfreespace){
Write-Host "Not Enough Disk Space on $TempPath for defragmentation process. Cannot continue.." -ForegroundColor Red
Break}

IF((get-childitem -Path $TempPath -Recurse -Filter "*.dit").Exists -eq "True"){
Write-Host "NTDS.DIT already exists - please remove first" -ForegroundColor Red
Break}

Write-Host ""
Write-Host "Compacting NTDS database..."
Write-Host ""
Write-Host "____________________________________________________________" -ForegroundColor Blue

# Compile NTDSUTIL required commands in series
$NTDSdbCompactor = ntdsutil "activate instance ntds" "files" "Compact to $TempPath" "q" "q"

#Execute compiled NTDSUTIL commands 
$NTDSdbCompactor

$NewDit= $TempPath + "\ntds.dit"
Write-Host ""

# Move newly compacted NTDS.DIT to the working DSA directory
Move-Item $NewDit $NTDSPath

# Clear the DSA Database Epoch key to indicate backup. Note: Future DS operations will error if this parameter isn't cleared
Remove-itemproperty -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters"  -name "DSA Database Epoch" -ErrorAction SilentlyContinue 

# Delete all logs for DB consistency
Remove-item $DitLogPath\*.log
Write-Host ""
Write-Host "NTDS Defragmentation Completed" -ForegroundColor Green
Write-Host ""
}

#Performs IFM (AD Snapshot) using NTDSUTIL

Function Create_FULL_IFM{
Write-Host "Security Warning: Be advised to store IFM files in a protected repository" -ForegroundColor Yellow -BackgroundColor Black
Write-Host ""
$IFMPath = Read-Host "Please enter a secured Target path for IFM files"
if ($IFMPath -eq ""){
Write-Host "Target Path unspecified. Cannot continue..." -ForegroundColor Red
Break}

$IFMdrive=$IFMPath.substring(0,2)
$IFMfreespace=(Get-WmiObject -Class Win32_volume -Filter "Driveletter = '$IFMdrive'").freespace
$NTDSDIT= (get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Database File")
$NTDSPath=(get-item -Path "HKLM:\SYSTEM\CurrentcontrolSet\Services\NTDS\Parameters").GetValue("DSA Working Directory")
$DITSize=(get-item -Path $NTDSDIT).Length

If($DITSize -le $IFMFreespace){
Write-Host "Available Free space on $IFMPath = $IFMfreespace - Good" -foregroundColor Green}
Else{ Write-Host "Not enough free space on $IFMPath = $IFMFreespace " -foregroundColor Red
Break}

If((get-childitem -Path $ifmpath -Recurse -Filter "*.dit").Exists -eq "True"){
Write-Host "AD Snapshot file already exists in $Ifmpath. Cannot continue operation" -ForegroundColor Red
Break}

# Check for running AD service. IF AD services are stopped, service will be started
$DSSRV=(Get-Service NTDS).Status
IF($DSSRV -ne "Running"){Start-Service NTDS -Confirm}

Write-Host "Creating Full IFM File package in $IFMPath ..."
Write-Host ""
Write-Host "____________________________________________________________" -ForegroundColor Blue
$IFMCMD = ntdsutil "activate instance NTDS" IFM "Create Full $IFMpath" quit quit
$IFMCMD 
$IFMFS=get-childitem -Path $IFMPath -Recurse -Verbose
foreach($IFMF in $IFMFS){$IFMTS=$IFMF.length + $IFMF.length}
Write-Host ""
Write-Host "Total size for IFM is $IFMTS"
Write-Host ""
}

# Switch Conditions

If($Move_NTDS_only){
If($DomainController -ne $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StopADDS}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:CheckDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:MoveDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StartADDS}
}

If($DomainController -EQ $env:COMPUTERNAME){
StopADDS
CheckDIT
MoveDIT
StartADDS
}
}

If($Move_DSLog_only){

If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:StopADDS}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:CheckDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:MoveLogs}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StartADDS}
}

If($DomainController -EQ $env:COMPUTERNAME){
StopADDS
CheckDIT
MoveLogs
StartADDS
}
}

If($Move_NTDS_FULL){
If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:StopADDS}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:CheckDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:MoveLogs}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:MoveDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StartADDS}
}

If($DomainController -eq $env:COMPUTERNAME){
StopADDS
CheckDIT
MoveLogs
MoveDIT
StartADDS
}
}

If($Offline_Defrag){
If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:StopADDS}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:Offline_Defrag}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StartADDS}
}
If($DomainController -eq $env:COMPUTERNAME){
StopADDS
Offline_Defrag
StartADDS
}
}

If($Create_FULL_IFM){
If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:Create_FULL_IFM}
}
If($DomainController -eq $env:COMPUTERNAME){
Create_FULL_IFM
}
}

If($DIT_Report){

If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:DIT_Report}
}

If($DomainController -eq $env:COMPUTERNAME){
DIT_Report
}
}

If($CheckDIT){
If($DomainController -NE $env:COMPUTERNAME){
$credential = $host.ui.PromptForCredential("Credentials for $DomainController", "Please enter Credentials for $DomainController","$env:userdomain\$env:username","")
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:StopADDS}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${Function:CheckDIT}
invoke-command -ComputerName $DomainController -Credential $credential -scriptblock ${function:StartADDS}
}

If($DomainController -eq $env:COMPUTERNAME){
StopADDS
CheckDIT
StartADDS
}
}

#FIN
