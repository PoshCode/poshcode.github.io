
 #############################################################################################
#
# NAME: Show-DriveSizes.ps1
# AUTHOR: Rob Sewell http://sqldbawiththebeard.com
# DATE:22/07/2013
#
# COMMENTS: Load function for displaying drivesizes
# USAGE: Show-DriveSizes server1
# ————————————————————————


Function Show-DriveSizes ([string]$Server)
{
                            $Date = Get-Date
                            Write-Host -foregroundcolor DarkBlue -backgroundcolor yellow "$Server - - $Date"
    #interogate wmi service and return disk information
                            $disks=Get-WmiObject -Class Win32_logicaldisk -Filter "Drivetype=3" -ComputerName $Server
                            $diskData=$disks | Select DeviceID, VolumeName , 
    # select size in Gbs as int and label it SizeGb
                            @{Name="SizeGB";Expression={$_.size/1GB -as [int]}},
    # select freespace in Gbs  and label it FreeGb and two deciaml places
                            @{Name="FreeGB";Expression={"{0:N2}" -f ($_.Freespace/1GB)}},
    # select freespace as percentage two deciaml places  and label it PercentFree 
                            @{Name="PercentFree";Expression={"{0:P2}"  -f ($_.Freespace/$_.Size)}}
                            $diskdata | Format-table -AutoSize | Out-Host
                                                  
}                                                      
