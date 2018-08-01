<#Script Synopsis
#Script Name: Clear_SoftwareDistribution.PS1
#Creator: Kevin Jackson 
#Date: 09/05/2016
#Updated: 09/05/2016


#Description: Script attempts to remove SCCM Client cache items and C:\Windows\SoftwareDistribution.
    (Optional) Force of CM Actions are added as well. 

.Example
Run Script from PowerShell ISE in Administrator mode.
#>

function ForEach-Parallel {
    param(
        [Parameter(Mandatory=$true,position=0)]
        [System.Management.Automation.ScriptBlock] $ScriptBlock,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [PSObject]$InputObject,
        [Parameter(Mandatory=$false)]
        [int]$MaxThreads=10
    )
    BEGIN {
        $iss = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $pool = [Runspacefactory]::CreateRunspacePool(1, $maxthreads, $iss, $host)
        $pool.open()
        $threads = @()
        $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param(`$_)`r`n" + $Scriptblock.ToString())
    }
    PROCESS {
        $powershell = [powershell]::Create().addscript($scriptblock).addargument($InputObject)
        $powershell.runspacepool=$pool
        $threads+= @{
            instance = $powershell
            handle = $powershell.begininvoke()
        }
    }
    END {

        $notdone = $true
        while ($notdone) {
            $notdone = $false
            for ($i=0; $i -lt $threads.count; $i++) {
                $thread = $threads[$i]
                if ($thread) {
                    if ($thread.handle.iscompleted) {
                        $thread.instance.endinvoke($thread.handle)
                        $thread.instance.dispose()
                        $threads[$i] = $null
                    }
                    else {
                        $notdone = $true
                    }
                }
            }
        }
    }
}
 
write-host `n
Read-Host Press Enter to continue 
Write-Host "Choose hostnames(computernames list) text file" -ForegroundColor yellow
######################################################################################
#File Prompt
######################################################################################
function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect)
{  
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = $WindowTitle
    if ($InitialDirectory -eq $Null) { $openFileDialog.InitialDirectory = $InitialDirectory } 
    $openFileDialog.Filter = $Filter
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
    $openFileDialog.ShowHelp = $true    
    $openFileDialog.ShowDialog() > $null
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}

$var = Read-OpenFileDialog("Select hostnames file:","c:\")

$Computers = Get-Content $var

Start-Sleep -s 3

 
  #$hostlist = Get-Content 'C:\clh\1.txt'
#Get-Content 'C:\temp\baseline_current_Overlap.txt'
#$Computers |ForEach-Parallel -MaxThreads 25
   
 # running through the list of hosts  
 $Computers |ForEach-Parallel -MaxThreads 10 {  

 if(Test-Connection $_ -quiet){


Invoke-Command -computername $_ -ScriptBlock { 

#Stops SMS Host Agent, Windows Update, Cryptographic Services and BITS
get-service ccmexec,wuauserv,cryptsvc,bits | where {$_.status -eq 'running'} | stop-service -Force -Verbose
Start-Sleep -Seconds 10

#Removes all of the files in the Software Distribution folder
Remove-Item C:\Windows\SoftwareDistribution\* -Recurse -Force -Verbose

#Removes all of the files in Windows\System32\CatRoot2 folder
#Remove-Item C:\Windows\System32\CatRoot2\* -Recurse -Force

#Removes the Windows Update log file
#Remove-Item C:\Windows\WindowsUpdate.log -Force

#Starts SMS Host Agent, Windows Update, Cryptographic Services and BITS
get-service ccmexec,wuauserv,cryptsvc,bits | where {$_.status -eq 'stopped'} | start-service -Verbose -Passthru

Start-Sleep -Seconds 10

# Removes ConfigMgr Client Cache items
$CMObject = New-Object -ComObject "UIResource.UIResourceMgr" -ErrorAction STOP
        $CMCacheObject = $CMObject.GetCacheInfo()
        foreach($CItem in $CMCacheObject.GetCacheElements()){
            $CMCacheObject.DeleteCacheElement($CItem.CacheElementId)
}

Start-Sleep -Seconds 10

#Force Scan Update
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000113}')

#Force Update CCM Evaluation Policy
([wmiclass]'ROOT\ccm:SMS_Client').TriggerSchedule('{00000000-0000-0000-0000-000000000108}')

Start-sleep -Seconds 30

#Force Update Installs
$UpdateList = [System.Management.ManagementObject[]](Get-WmiObject -ComputerName $_ -Query 'SELECT * FROM CCM_SoftwareUpdate' -Namespace ROOT\ccm\ClientSDK);([wmiclass]"\\$_\ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager").InstallUpdates($UpdateList);


    }

}

}





