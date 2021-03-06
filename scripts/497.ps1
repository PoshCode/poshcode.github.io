Function Get-Utilization {
    Param([string]$computername=$env:computername,
          [string]$ID="C:"
          )
          
     #suppress errors messages    
    $errorActionPreference="silentlycontinue"      
          
    $drive=Get-WmiObject Win32_Logicaldisk -filter "DeviceID='$ID'" `
    -computername $computername -errorAction "silentlycontinue"
    
    if ($drive.size) {
    
        #divide size and freespace by 1MB because they are UInt64
        #and I can't do anything with them in there native type
        
        $size=$drive.size/1MB
        $free=$drive.freespace/1MB
          
        $utilization=($size-$free)/$size
        
        write $utilization
    }
    else {
    #there as an error so return a value that can't be mistaken
    #for drive utilization
        write -1
    }

}

#Sample usage
$computer="PUCK"
$drive="C:"
$u=Get-Utilization $computer $drive

#format $u as a percentage to 2 decimal points

$percent="{0:P2}" -f $u

if ($u -eq -1) {
    $msg="WARNING: Failed to get drive {0} on {1}" -f $drive,$computer
    $color="RED"
}
elseif ($u -ge .75) {
    $msg="WARNING: Drive {0} on {1} is at {2} utilization." -f $drive,$computer,$percent
    $color="RED"
}
else {
    $msg="WARNING: Drive {0} on {1} is at {2} utilization." -f $drive,$computer,$percent
    $color="GREEN"
}

Write-Host $msg -foregroundcolor $color

