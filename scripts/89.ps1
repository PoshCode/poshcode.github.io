Param($BackupLocation,$list,$FromAD,[switch]$clear)
# For more info read the following blog entry
# http://www.bsonposh.com/modules/wordpress/?p=41
function Get-ADComputers{
    $filter = "(&(objectcategory=computer))"
    $root = [ADSI]""
    $props = "dNSHostName","sAMAccountName"
    $Searcher = new-Object System.DirectoryServices.DirectorySearcher($root,$filter,$props)
    $Searcher.PageSize = 1000
    $Computers = $Searcher.findAll() | %{$_.properties['dnshostname']}
    $Computers 
}
function Ping-Server {
   Param([string]$server)
   $pingresult = Get-WmiObject win32_pingstatus -f "address='$Server'"
   if($pingresult.statuscode -eq 0) {$true} else {$false}
}

if($FromAD){$computers = Get-ADComputers}
else{if($list){$computers = get-Content $list}else{Write-Host "Please Provide List";return}}

foreach($computer in $computers)
{
    if(ping-server $computer)
    {
        $Folder = "{1}-Logs-{0:MMddyymm}" -f [DateTime]::now,$computer
        Write-Host "+ Processing Server $Computer"
        New-Item "$backupLocation\$folder" -type Directory -force  | out-Null
        If(!(Test-Path "\\$computer\c$\LogBackups")){New-Item "\\$computer\c$\LogBackups" -type Directory -force | out-Null}
        $Eventlogs = Get-WmiObject Win32_NTEventLogFile -ComputerName $computer
        Foreach($log in $EventLogs)
        {
            $path = "\\{0}\c$\LogBackups\{1}.evt" -f $Computer,$log.LogFileName
            $result = ($log.BackupEventLog($path)).ReturnValue
            Copy-Item $path -dest "$backupLocation\$folder" -force
            if($clear)
            {
                $log.clear()
            }
        }
    }
}
