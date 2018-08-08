# Invoke-VMCommand.ps1
# Purpose     : Run a remote command and return the results
# Requirements: plink.exe from the Putty project must be in $env:path
# Use -help parameter for instructions

Param (
    $VMHost,
    $username,    
    $Command,
    [switch]$Help,
    [switch]$Verbose
)

# Obtains list of VMX (config files) corresponding to each VM on a given ESX server
function GetVMX ($user, $pass, $srv) {
    $cmd = "plink.exe $user@$srv -pw $pass"
    $cmd += " vmware-cmd -l"
    Write-Verbose "Command line: $cmd"
    $VMList = Invoke-Expression $cmd
    $collOut = @()
    $VmList | ForEach-Object {
        $objOut = "" | Select-Object VmHost, VmName, VMXpath, HasSnapshot # create our output object with desired properties
        $objOut.VmHost = $srv
        $objOut.VMXpath = $_
        $objOut.VmName = (Split-Path $_ -Leaf) -replace ".vmx$"
        $collOut += $objOut
    }
    $collOut
}
function Get-ESXProcess($user, $pass, $srv){
    $cmd =  "plink.exe -t $user@$srv -pw $pass "
    $cmd += "`"ps -Af | grep `'`'`""
    Write-Verbose "Command line: $cmd"
    $results = invoke-Expression $cmd
    $colObj = @()
    foreach($result in $results)
    {
        if($result -match "^UID"){continue}
        $myobj = "" | Select-Object UID,PID,PPID,C,STIME,TTY,TIME,CMD
        $ary = $result.split([string[]]" ",[System.StringSplitOptions]::RemoveEmptyEntries)
        $myobj.UID   = $ary[0]
        $myobj.PID   = $ary[1]
        $myobj.PPID  = $ary[2]
        $myobj.C     = $ary[3]
        $myobj.STIME = $ary[4]
        $myobj.TTY   = $ary[5]
        $myobj.Time  = $ary[6]
        $proc = $null
        write-verbose "Length: $($ary.Length)"
        for($i = 7;$i -le $ary.Length;$i++)
        {
            $proc = "$proc $($ary[$i])"
            write-Verbose "Adding [$i] $($ary[$i])"
        }
        Write-Verbose "COMMAND = $proc"
        $myobj.CMD   = $proc
        $colObj += $myobj
    }
    $colObj
}
function Kill-Process{
    Param($User,$Pass,$Srv,$killcmd)
    $cmd =  "plink.exe -t $user@$srv -pw $pass "
    $killme = $killcmd.split(":")[1]
    Write-Verbose " - $killcmd"
    Write-Verbose " - $killme"
    if($killme -notmatch "^\d")
    {
        $vmprocess = Get-ESXProcess $User $Pass $Srv | where{$_.Cmd -match $killme}
        $vmpid = $vmprocess.pid
    }
    else
    {
        $vmpid = $killme
    }
    $cmd += "`"kill -9 $vmpid`'`'`""
    $results = invoke-Expression $cmd
    $results
}
function RunVMCommand ($user, $pass, $srv, $vmcmd) {
    $cmd = "plink.exe $user@$srv -pw $pass "
    $cmd += "`"$vmcmd | grep `'`'`""
    Write-Verbose "Command line: $cmd"
    invoke-Expression $cmd
}
function GetSecurePass ($SecurePassword) {
  $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecurePassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
  [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
  $password
}


# Returns help text
function ShowUsage {
  $helptext = @"

Invoke-VMCommand
  Requirements: plink.exe from the Putty project must be in your Path
  
INPUT: 

  VMHost     : name or IP of ESX server(s) (REQUIRED)
  UserName   : User to ssh With (REQUIRED)
  Command    : Command to Run. This can be a GetVMX, PSList, Kill:<PID/VMName>, or a Custome String (REQUIRED)
  Help       : shows usage

"@
  Write-Host $helptext
}

# Main
if ($help) { ShowUsage; exit; }
if ($verbose) { $verbosepreference = "continue" }

$password = (Read-Host "Enter Password" -AsSecureString)

if($Command -eq "GetVMX"){GetVMX $username (GetSecurePass $password) $VMHost}
elseif($command -eq "PSList"){Get-ESXProcess $username (GetSecurePass $password) $VMHost}
elseif($command -match "^KILL"){Kill-Process $username (GetSecurePass $password) $VMHost $command}
else{RunVMCommand $username (GetSecurePass $password) $VMHost $Command}
