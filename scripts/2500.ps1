###############################################################################
# Use Unregister-Event -SourceIdentifier <name> -Force (to stop an Event).
# Include script in $profile to register all these events. Modify to suit own
# requirements and comment out any of the examples below that are not needed. 
# Please visit www.SeaStarDevelopment.Bravehost.com for more utilities.
###############################################################################
# This ACTION will trap Script start/stop events (SourceId = ScriptMonitor); but
# only if started externally via 'powershell.exe -noexit -command & example.ps1'
# NOTE: this duplicates the actions of Script Monitor Service and both should 
# not be run together (Uncomment the lines below to start). 
###############################################################################

$action = {
    $pattern = '^(.*)(\s+|\\)([-_a-z0-9]+\.(?!(psc1))[a-ehmpstv1]{3,4})\b'
    $script = $msg = 'BLANK'
    $e = $Event.SourceEventArgs.NewEvent
    $process   = $e.TargetInstance.Name
    $processID = $e.TargetInstance.ProcessId
    $cmdline   = $e.TargetInstance.CommandLine
    If ($cmdline -match $pattern) {
        $script = $matches[3]
        $path = $matches[1]
        If ($path -match '^.*( sc|/TR ).*$') {       #Skip lines with SC or /TR
            $script = 'BLANK'
        }
    }
    Switch ($e.__CLASS) {
        '__InstanceCreationEvent' { 
            If ($script -ne 'BLANK') {
                $msg  = "Script Job: $script ($processID) started."
                $time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
                $tag  = "$time [$script] start. --> $cmdline"
                $ID   = "2"
            }
        }
        '__InstanceDeletionEvent' {
            If ($script -ne 'BLANK') { 
                $msg  = "Script Job: $script ($processID) ended."
                $time = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
                $tag  = "$time [$script] ended. --> $cmdline"
                $ID   = "1"
            }
        }
        Default                   {$_ | Out-Null }
    }
    If ($cmdline.StartsWith("cscript") -and $cmdline.Contains("//logo")) {
        $msg = 'BLANK'       #Skip duplicate entry from Notepad Script Editor.
    }
    If ($msg -ne 'BLANK') {
        $file = Join-Path (get-Location) "Monitor.txt"
        If (Test-Path $file) {
            $tag | Out-File $file -encoding 'Default' -Append
        }
        Write-LogEvent Scripts $ID $msg
    }
}    
     
$query = "SELECT * FROM __InstanceOperationEvent WITHIN 2 WHERE `
     TargetInstance ISA 'Win32_Process' AND `
    (TargetInstance.Name = 'cmd.exe' OR `
     TargetInstance.Name = 'wscript.exe' OR `
     TargetInstance.Name = 'Cscript.exe' OR `
     TargetInstance.Name = 'mshta.exe')"
#Register-WmiEvent -Query $query -SourceIdentifier ScriptMonitor -Action $action `
#    | Out-Null
 
###############################################################################
#This ACTION will trap any USB insertions (SourceId = USBdevice).
###############################################################################
$action1 = {
    $file   = 'c:\Scripts\AutoAvast.vbs'    #Change to run desired script, etc.
    $e = $Event.SourceEventArgs.NewEvent
    $drive  = $e.TargetInstance.DeviceID
    $volume = $e.TargetInstance.VolumeName
    $free   = $e.TargetInstance.FreeSpace
    $size   = $e.TargetInstance.Size
    If ($e.TargetInstance.VolumeSerialNumber -ne "") {
        & 'c:\windows\system32\wscript.exe' $file $drive $volume $free $size
    }
}
$query1 = "SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE `
    TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DriveType = 2"

Register-WmiEvent -Query $query1 -SourceIdentifier USBdevice -Action $action1 `
    | Out-Null

###############################################################################
#This ACTION will trap any file downloads (SourceId = Download).
###############################################################################
$action2 = {
    $eventLog = "Internet Explorer"
    $id = 99
    $e = $Event.SourceEventArgs.NewEvent
    $drive  = $e.TargetInstance.Drive
    $file   = $e.TargetInstance.FileName + "." + `
              $e.TargetInstance.Extension
    $path   = $e.TargetInstance.Path
    $folder = $drive + "\Downloads"
    Switch ($e.TargetInstance.Extension) {
        'exe'   {$id = 20; break}
        'enu'   {$id = 21; break}
        'html'  {$id = 23; break}
        'zip'   {$id = 24; break}
        'rar'   {$id = 25; break}
        'msi'   {$id = 29; break}
        Default {$id = 99}
    }
    $formatString = "{0:##.#}Mb"
    $size = $formatString -f ($e.TargetInstance.FileSize/1KB)
    $desc = "File $file has been added to the $folder folder; filesize = $size" 
    Write-LogEvent $eventLog $ID $desc
}
$query2 = "SELECT * FROM __InstanceCreationEvent WITHIN 30 WHERE TargetInstance `
    ISA 'CIM_DataFile' AND TargetInstance.Path = '\\Downloads\\' AND `
        (TargetInstance.Drive = 'C:' OR TargetInstance.Drive = 'E:')"

Register-WmiEvent -Query $query2 -SourceIdentifier Download -Action $action2 `
    | Out-Null

###############################################################################
#This ACTION will catch Avast Database Update (SourceId = FileWatcher)
#Change to run any script, etc. (Prompter.exe is now included in the Scripting
#Editor download from www.SeaStarDevelopment.Bravehost.com and is used to put
# a message in the notification area). Uncomment the 2 lines below to run.
###############################################################################
$action3 = {
    $file = $Event.SourceEventArgs.Name
    & 'c:\Scripts\prompt.exe' /Notify update /Title Avast Update Service `
      /Msg Updating file: $file
}

$folder = "c:\Program Files\Alwil Software\Avast5\Setup"
$filter = "*.vpx"
$fsw = New-Object -TypeName System.IO.FileSystemWatcher -ArgumentList `
    $folder, $filter
$fsw.IncludeSubDirectories = $false
$fsw.EnableRaisingEvents   = $true
#Register-ObjectEvent -InputObject $fsw -EventName "Changed" `
#    -SourceIdentifier FileWatcher -Action $action3 | Out-Null

###############################################################################
#This ACTION runs Ccleaner and Keylog Backup (SourceId = UnHibernate)
###############################################################################
$action4 = {
    $file = "c:\scripts\KeylogBackup.vbs"
    $args = $Event.SourceEventArgs.NewEvent.EventType    #Type 18 = UnHibernate.
    & 'c:\windows\system32\wscript.exe' $file $args
    & "$env:programfiles\ccleaner\ccleaner.exe" /AUTO
}
$query4 = "SELECT * FROM Win32_PowerManagementEvent WHERE EventType = '18'"

Register-WmiEvent -Query $query4 -SourceIdentifier UnHibernate -Action $action4 `
    | Out-Null

###############################################################################
#This ACTION will detect Avast Database changes (Updates). Replaces 3 above.
###############################################################################
$action5 = {
    & 'c:\Scripts\prompt.exe' /Notify update /Title Avast Update Service `
       /Msg Starting database update
    Write-Eventlog -logname Antivirus -source avast -eventID 90 -entryType `
        Information -message "Avast5 Automatic Database Update"
}
$query5 = "SELECT * FROM __InstanceCreationEvent WITHIN 180 WHERE `
    TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'avast.setup'"

Register-WmiEvent -Query $query5 -SourceIdentifier Avast -Action $action5 `
    | Out-Null

###############################################################################
#This ACTION will detect Windows Media Player & then start ActiveSyncToggle
###############################################################################
$action7 = {
    $e = $Event.SourceEventArgs.NewEvent
    If (Test-Path "e:\downloads\ActiveSyncToggle.exe") {
        & 'e:\downloads\ActiveSyncToggle.exe'
    } 
}
$query7 = "SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE `
    TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = 'wmplayer.exe'"

Register-WmiEvent -Query $query7 -SourceIdentifier MediaPlayer -Action $action7 `
    | Out-Null
 
###############################################################################
# This ACTION will detect any changes to the registry HKLM\Run key.
###############################################################################
$hive = "HKEY_LOCAL_MACHINE"
$keyPath = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"

$action8 = {
    $file = 'c:\Scripts\HKLMrun.vbs' 
    & 'c:\windows\system32\wscript.exe' $file 
}
$query8 = "SELECT * FROM RegistryKeyChangeEvent WHERE Hive = '$hive' AND KeyPath = '$keyPath'"

Register-WmiEvent -Query $query8 -Namespace 'root\default' `
    -SourceIdentifier HKLMRunKey -Action $action8 | Out-Null
 
###############################################################################
# To capture scripts started within the current session a 'Run' function (below) 
# should be added to the $profile, and each script should then be started with 
# Run example.ps1, etc. The $logfile is created by the Script Monitor Service.
#
# Function Run([String]$scriptName = '-BLANK-') {
#     $logfile = "$env:programfiles\Sea Star Development\" + 
#         "Script Monitor Service\ScriptMon.txt"
#     $parms  = $myInvocation.Line -replace "run(\s+)$scriptName(\s*)"
#     $script = $scriptName -replace "\.ps1\b"     #Replace from word end only.          
#     $script = $script + ".ps1"
#     If (Test-Path $pwd\$script) {
#         If(!(Test-Path Variable:\Session.Script.Job)) {
#             Set-Variable Session.Script.Job -value 1 -scope global `
#                 -description "Script counter"
#         }
#         $Job    = Get-Variable -name Session.Script.Job
#         $number = $job.Value.ToString().PadLeft(4,'0')
#         $job.Value += 1                #Increment here in case script aborts.
#         $startTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
#         $tag = "$startTime [$script] start. --> $($myInvocation.Line)"
#         If (Test-Path $logfile) {
#             $tag | Out-File $logfile -encoding 'Default' -Append
#         }
#         Write-LogEvent Scripts 2 "Script Job: $script (PS$number) started."
#         Invoke-Expression -command "$pwd\$script $parms"
#         $endTime = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
#         $tag = "$endTime [$script] ended. --> $($myInvocation.Line)"
#         If (Test-Path $logfile) {
#             $tag | Out-File $logfile -encoding 'Default' -Append
#         }
#         Write-LogEvent Scripts 1 "Script Job: $script (PS$number) ended."
#     }
#     Else {
#         Write-Error "$pwd\$script does not exist."
#     }
# }
###############################################################################




