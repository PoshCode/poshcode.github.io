#requires -version 2.0
###############################################################################
## New-ElevatedTask is a script (for Vista) which creates "elevated" scheduled 
## tasks by exploiting the import-from XML feature of schtasks.exe /Create /XML
##
## Creates a new "On Demand Only" scheduled task to run an "Elevated" application 
## on Vista, so it MUST be run from an elevated prompt ... and then creates a 
## shortcut to run that scheduled task on demand via schtasks.exe /run /tn
##
## NOTE: Depends on my New-Shortcut script which is also available on the script
## repository at http://powershellcentral.com/scripts/?q=New-Shortcut
##
## Version History
## 2.0 - First version with shortcut support
##     - Still weak on documentation of the arguments, sorry ...
## 2.5 - Improved defaults and documentation (run with -?)
## 2.6 - CTP 3 version, with AutoHelp and CmdletBinding
## 2.7 - Windows 7 version (PowerShell 2) to support different XML ...
#function New-ElevatedTask {
<#
.SYNOPSIS
	Creates a new "On Demand Only" scheduled task to run an "Elevated" application, and a shortcut to launch it.
.DESCRIPTION
	New-ElevatedTask creates a scheduled task on Vista or Windows7 which runs "On Demand" with full priviledges (Elevated) and then creates a shortcut to launch it on demand.

   It works by exploiting the import from XML feature of schtasks.exe /Create /XML ... and the ability to run tasks on demand via schtasks.exe /run /tn ...

   You may specify the shortcut path as a folder path (which must exist), with a name for the new file (ending in .lnk), or you may specify one of the "SpecialFolder" names like "QuickLaunch" or "CommonDesktop" followed by the name.  The shortcut feature depends on the New-Shortcut function (a separate script).

	
	NOTE: You MUST run this in an elevated PowerShell instance.

.Example
	New-ElevatedTask C:\Windows\Notepad.exe
		Will create a task to run notepad elevated, and creates a shortcut to run it the current folder, named "Notepad.lnk"
	
.Example
	New-ElevatedTask C:\Windows\Notepad.exe -Shortcut QuickLaunch\Editor.lnk -FriendlyName "Run Notepad" -TaskName "Elevated Text Editor"
		Will create a task to run notepad elevated, and names it "Elevated Text Editor". Also creates a shortcut on the QuickLaunch bar with the name "Run Notepad.lnk" and the tooltip "Elevated Text Editor"

.NOTE
   Must be run from an elevated PowerShell instance
   Some features depend on New-Shortcut (which is also available on the repository: http://PoshCode.org/search/New-Shortcut)
#>
[CmdletBinding()]
param(
   $TargetPath       = ""
,  $Arguments        = ""
,  $WorkingDirectory = $(Split-Path -parent (Resolve-Path $TargetPath))
,  $FriendlyName     = $(Split-Path $TargetPath -leaf)
,  $TaskName         = $( "Elevated $friendlyName" )
,  $IconLocation     = $null
,  $ShortcutPath     = $null
,  $Hotkey           = $Null
,  $UserName         = $null
,  $password         = $null
,
   [System.Management.Automation.PSCredential]
   $credential       = $null
)

$SchTasks = Join-Path ([Environment]::GetFolderPath("System")) "schtasks.exe"

if(-not (Test-Path $SchTasks) ) {
	$SchTasks = Read-Host "You need to set the correct location for the SchTasks.exe application on your system"
}



if(!(Test-Path $TargetPath)) {
	Write-Error "TargetPath must be an existing file for the scheduled task to point at!"
	return
}
if([Environment]::OSVersion.Version.Major -lt 6) {
   Write-Warning "OS not supported $([Environment]::OSVersion.VersionString)"
   Write-Warning "Only Vista and up support the xml tasks, as far as I know"
	return
}

$win7 = [bool][Environment]::OSVersion.Version.Minor

if($win7) {
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
"@
} else {
$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
"@
}
$xml += @"
  <RegistrationInfo>
    <Author>{4}</Author>
    <Description>Run {0} "As Administrator"</Description>
  </RegistrationInfo>
  <Triggers />
  <Principals>
    <Principal id="Author">
      <UserId>{4}</UserId>
      <LogonType>{5}</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Actions Context="Author">
    <Exec>
      <Command>{1}</Command>
      <Arguments>{2}</Arguments>
      <WorkingDirectory>{3}</WorkingDirectory>
    </Exec>
  </Actions>
  <Settings>
    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
"@
if($win7) {
$xml += @"
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine>
  </Settings>
</Task>
"@ 
} else {
$xml += @"
  </Settings>
</Task>
"@ 
}

$xFile = [IO.Path]::GetTempFileName()

# if they specify a user name, assume they want to do password authentication
if($UserName -ne $null -and $password -ne $null)  {
  $xml -f $friendlyName, $TargetPath, $arguments, $WorkingDirectory, $UserName, "Password" | set-content $xFile
  &$SchTasks /Create /XML $xFile /TN $taskname /RU $UserName /RP $password

  # if they didn't include a password, prompt them for one ...
} elseif($UserName -ne $null -and $password -eq $null)  {
  $xml -f $friendlyName, $TargetPath, $arguments, $WorkingDirectory, $UserName, "Password" | set-content $xFile
  &$SchTasks /Create /XML $xFile /TN $taskname /RU $UserName /RP

  # if they supplied credentials instead, use that
} elseif($credential -ne $null) {
  $xml -f $friendlyName, $TargetPath, $arguments, $WorkingDirectory, $($Credential.UserName), "Password" | set-content $xFile

  &$SchTasks /Create /XML $xFile /TN $taskname /RU $credential.UserName /RP $($Credential.GetNetworkCredential().Password)

} else {
  # if they suppplied neither user nor credentials, lets assume they want the "current" user
    $UserName = ([Security.Principal.WindowsIdentity]::GetCurrent().Name)

  # if they passed a password, use that
  if($password -ne $null) {
    $xml -f $friendlyName, $TargetPath, $arguments, $WorkingDirectory, $UserName, "Password" | set-content $xFile
    &$SchTasks /Create /XML $xFile /TN $taskname /RU $UserName /RP $password
  
  # otherwise, there are no special credentials needed, "Interactive" means only "this" user can run it.
  } else {
    $xml -f $friendlyName, $TargetPath, $arguments, $WorkingDirectory, $UserName, "InteractiveToken" | set-content $xFile
    &$SchTasks /Create /XML $xFile /TN $taskname
  }
}

if(!$IconLocation) {
	$IconLocation = $TargetPath
}
if($ShortcutPath -and (Get-Command New-Shortcut -ErrorAction SilentlyContinue)) {
   if(([IO.FileInfo]$ShortcutPath).Extension.Length -eq 0 ) {
    $ShortcutPath = "$ShortcutPath\$FriendlyName.lnk"
	$Description  = $TaskName
   } else {
	$Description  = $FriendlyName
   }
   ## New-ShortCut $TargetPath $LinkPath $Arguments $WorkingDirectory $WindowStyle $IconLocation $Hotkey $Description
   if(Get-Command New-Shortcut -ErrorAction SilentlyContinue) {
      New-Shortcut -Target $SchTasks -LinkPath $ShortcutPath -Arg "/Run /TN `"$TaskName`"" -WorkingDirectory $WorkingDirectory -Window "Minimized" -Icon $IconLocation -Hotkey $Hotkey -Description $Description
   }
}
#}
