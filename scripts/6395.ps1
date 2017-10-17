﻿Function Confirm-DiskExists
{
<#
.Synopsis
   Checks if a specific disk exists.

.DESCRIPTION
   Checks if a specific disk, e.g., C: exists on the machine. It returns True or False plus optional verbose messages.

.INPUTS
    Disk letter (required), e.g., C:.

.OUTPUTS
   True or False. When the -Verbose switch is used it shows more details.
    
.EXAMPLE
   Confirm-DiskExists -DiskLetter C: 
        This checks disk C: exists

.EXAMPLE
   Confirm-DiskExists -DiskLetter E: -Verbose
        This checks disk E: exists and write a verbose message:
        "Disk E: exists" 
        or 
        "Disk E: does not exist on this machine"
         
.EXAMPLE
   Confirm-DiskExists C:
        This checks disk C: exists without specifying the parameter name, using its positional location at position 0.

.EXAMPLE
   Confirm-DiskExists E: -Verbose
   This checks disk E: exists without specifying the parameter name, using its positional location at position 0.
        It will also show a verbose message:
        "Disk E: exists" 
        or 
        "Disk E: does not exist on this machine"       
#>

[CmdletBinding(PositionalBinding=$true)]
    [OutputType([bool])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter the drive letter followed by a colon, e.g., C:",
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(2,2)]
        [ValidateSet("A:", "B:", "C:", "D:", "E:", "F:", "G:", "H:", "I:", "J:", "K:", "L:", "M:", "N:", "O:", "P:", "Q:", "R:", "S:", "T:", "U:", "V:", "W:", "X:", "Y:", "Z")]
        [Alias("DeviceID","disk", "d")]
        [string]
        $DiskLetter
    )

    Process
    {
        $diskMeasure = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID = '$DiskLetter'" | Measure-Object
        $diskCount = $diskMeasure.Count
        if($diskCount -eq 1) { 
            Write-Verbose "Disk $DiskLetter exists"
            return $true 
            } else { 
            Write-Verbose "Disk $DiskLetter does not exist on this machine"
            return $false 
            } 
    }
}


Function Confirm-FreeSpace
{
<#
.Synopsis
   Checks enough free disk space.

.DESCRIPTION
   Checks that a disk has an amount (in GB) of free space. It returns True or False plus optional verbose messages.

.INPUTS
    Disk letter (required) and minimum free GB (if not specified it uses a default value of 10GB).

.OUTPUTS
   True or False. When the -Verbose switch is used it shows the the free space details.
   
.EXAMPLE
   Confirm-FreeSpace -DiskLetter C: -MinGB 30
        This checks disk C: for minimum free space of 30GB

.EXAMPLE
   Confirm-FreeSpace -DiskLetter C: -MinGB 30 -Verbose
        This checks disk C: for minimum free space of 30GB and writes the amount of free space
        
.EXAMPLE
   Confirm-FreeSpace -DiskLetter C:
   This specifies just the disk letter, using the fact that MinGB parameter has a default value of 10GB
        This checks disk C: for minimum free space of 10GB

.EXAMPLE
   Confirm-FreeSpace -DiskLetter E: -MinGB 500
        This checks disk E for minimum free space of 500GB

.EXAMPLE
   Confirm-FreeSpace C: 10
   This uses the positional parameters, disk name first then the min. free space.
        It will check disk C: for minimum free space of 10GB

.EXAMPLE
   Confirm-FreeSpace -disk D: -min 20
   This uses the alias -disk for -DiskLetter and -min for -MinGB
        It will check disk D: for minimum free space of 20GB

.EXAMPLE
   Confirm-FreeSpace -d D: -m 20
   This uses the alias -d for -DiskLetter and -m for -MinGB
        It will check disk D: for minimum free space of 20GB

.EXAMPLE
   "C:", "D:", "E:" | Confirm-FreeSpacE -ErrorAction Stop
   This passes an array of 3 disks to the pipe line to the command.
        It will process 3 checks, one for each disk, using the default value of 10GB for the MinGB parameter

.EXAMPLE
   Get-WmiObject -Class Win32_LogicalDisk | Confirm-FreeSpacE -ErrorAction Stop -Verbose
   This passes all the disks received from WMI command through the pipe line to the command.
        For each disk it will do the check. The verbose output would look something like this:

        VERBOSE: Disk C: exists
        VERBOSE: Disk C: has 376 GB free
        True
        VERBOSE: Disk D: exists
        VERBOSE: Disk D: has only 0 GB free. It is less than the the minimum of 10 GB
        False
        VERBOSE: Disk X: exists
        VERBOSE: Disk X: has only 0 GB free. It is less than the the minimum of 10 GB
        False
        VERBOSE: Disk Y: exists
        VERBOSE: Disk Y: has only 1 GB free. It is less than the the minimum of 10 GB
        False

.EXAMPLE
   Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{N="MinGB";E={ 30 }} | Confirm-FreeSpacE -ErrorAction Stop -Verbose
   This takes all the disks from WMI command, adds a custom property MinGB set to 30 and passes to this command through the pipeline.
        For each disk it will do the check like in the above example, but with 30GB as the minimim value.
       
#>

    [CmdletBinding(PositionalBinding=$true)]
    [OutputType([bool])]
    Param
    (
        # DiskLetter help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter just the drive letter followed by a colon, e.g., C:",
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(2,2)]
        [ValidateSet("A:", "B:", "C:", "D:", "E:", "F:", "G:", "H:", "I:", "J:", "K:", "L:", "M:", "N:", "O:", "P:", "Q:", "R:", "S:", "T:", "U:", "V:", "W:", "X:", "Y:", "Z")]
        [ValidateScript({ Confirm-DiskExists $_})]
        [Alias("DeviceID","disk", "d")] 
        [string]
        $DiskLetter,

        # MinGB help description
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter an integer for the minimum amount of hard-disk free GB space",
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("min", "m")] 
        [int]
        $MinGB = 10
    )

    Process
    {
        Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID = '$DiskLetter'" |
        Select-Object DeviceID, FreeSpace, 
        @{Name="FreeGB"; Expression={$_.FreeSpace/1GB -as [int]}} | 
        ForEach-Object { 
            if($_.FreeGB -lt $MinGB) {
                    Write-Verbose "Disk $DiskLetter has only $($_.FreeGB) GB free. It is less than the the minimum of $MinGB GB"
                    return $false
                } else {
                Write-Verbose "Disk $DiskLetter has $($_.FreeGB) GB free" 
                return $true
            } 
        }
    }
}

