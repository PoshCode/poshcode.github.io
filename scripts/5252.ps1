function Get-OSInfo {
<#
.SYNOPSIS
Gets OS info.

.DESCRIPTION
Uses CIM, so PowerShell 3+ needs to be on all target nodes.

.PARAMETER Computername
The name of the computer. Duh.

.PARAMETER ErrorLogFile
Defaults to c:\errors.txt; this is the text file where
the names of failed computers will be saved. This file
will be deleted, if it exists, when the command runs.

.EXAMPLE
Get-OSInfo -Computername DC,S1
This example gets Os info from two computers.

.EXAMPLE
"s1","s2" | Get-OSInfo
This example gets OS info from two computers, but accepts
their names from the pipeline.
#>
    [CmdletBinding()]
    param(

        # One or more canonical computer names
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   HelpMessage='Computer name to query')]
        [ValidateNotNullOrEmpty()] #about_functions_advanced_parameters
        [Alias('cn','hostname')]
        [string[]]$ComputerName,

        # Text file to log failed computer names
        [Parameter(HelpMessage='Text file for failed computer names')]
        [string]$ErrorLogFile = 'c:\errors.txt'
    )

    # This runs before anything else in the function
    BEGIN {

        # start with a fresh file each time
        Write-Verbose "Removing $ErrorLogFile"
        Remove-Item -Path $ErrorLogFile -ErrorAction SilentlyContinue

    }

    # When input is piped, this runs once for each piped object
    # Otherwise this runs once with all info in parameters
    PROCESS {

        # enumerate computers
        foreach ($computer in $computername) {
            try {

                # trapping connection fail on first query
                Write-Verbose "Connecting to $computer"
                $os = Get-CimInstance -Class Win32_OperatingSystem -Comp $Computer  -ErrorAction Stop
                $compsys =Get-CimInstance -Class Win32_ComputerSystem -Comp $Computer

                # translate mfgr name
                switch ($compsys.Manufacturer) {
                    'Microsoft ' { $mfgr = 'MS' }
                    'Dell'       { $mfgr = 'Dell Computer' }
                    default      { $mfgr = $compsys.Manufacturer }
                }
                Write-Verbose "Manufacturer is now $mfgr, OS version is $($os.version)"

                # construct output properties
                $output = @{'ComputerName' = $computer;
                            'OSVersion'    = $os.version;
                            'SPVersion'    = $os.ServicePackMajorVersion;
                            'Mfgr'         = $mfgr;
                            'Model'        = $compsys.Model}

                # get the disks
                $disks_array = @()
                $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $Computer
                foreach ($disk in $disks) {
                    $disk_object_props = @{'DriveLetter'=$disk.DeviceID;
                                           'Size'=$disk.Size;
                                           'FreeSpace'=$disk.FreeSpace}
                    $disk_object = New-Object -TypeName PSObject -Property $disk_object_props
                    $disks_array += $disk_object
                }

                #append the disks to the output properties
                $output.add('Disks',$disks_array)

                # emit output object
                $object = New-Object -TypeName PSObject -Property $output
                $object.psobject.typenames.insert(0,'MyTools.OSInfo.Output.Thing')
                Write-Output $object

            } catch {

                # display error and log failed
                # computer name to file
                $oops = $_
                $Computer | out-file -FilePath $ErrorLogFile -Append
                Write-Warning "OMG, $computer failed"
                Write-Warning "Apparently, $oops"

            }#trycatch
        }#foreach computer
    }#process
}#function

function Set-ServiceLogonPassword {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [Alias('DNSHostName')]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$True)]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [string]$NewPassword
    )
    PROCESS {
        
        foreach ($computer in $computername) {

            $rv = Get-CimInstance  -ClassName Win32_Service `
                                   -Filter "name='$servicename'" `
                                   -ComputerName $computer |
                  Invoke-CimMethod -MethodName Change `
                                   -Arguments @{'StartPassword'=$NewPassword}

            if ($rv.returnvalue -ne 0) {
                Write-warning "It didn't work on $computer for $servicename. Panic."
            }

        }

    }
}
