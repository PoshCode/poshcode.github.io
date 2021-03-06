    # Directions for use:
    # Import this script using the Import-Module cmdlet
    # All output is logged to the backup directory in the $($BackupDriveLetter):\VMBackup\Backup-VMs.log file
    # Use the Backup-VMs cmdlet to begin the process
    #       Parameter BackupDriveLetter indicates the drive to put this backup onto. It must be mounted to the host running the script.
    #       Parameter VMHost defines the host that contains the VMs you want to back up. If it's blank, then it just targets the host the script is running on
    #       Parameter VMNames defines the specific VMs you wish to backup, otherwise it'll back up all of them on the target host
    #       Switch parameter ShutHostDownWhenFinished will cause the specified host (and any VMs running on it) to shut down upon completion of the backup
    # Example:
    # PS> Import-Module D:\Backup-VMs.ps1
    # PS> Backup-VMs -BackupDriveLetter F -VMHost HyperVHost -VMNames mydevmachine,broker77

    # ----------------------------------------------------------------------------
    # Note that this script requires administrator privileges for proper execution
    # ----------------------------------------------------------------------------

    # Note that this script requires the following:
    #
    # PowerShell Management Library for Hyper-V (for the Get-VM and Export-VM cmdlets)
    # This installs itself wherever you downloaded it - make sure the Hyper-V folder finds its way to somewhere in $env:PSModulePath
    # http://technet.microsoft.com/en-us/library/hh848559.aspx
    #
    # .Net 4.5 (for the CreateFromDirectory zip method)

    # our one global variable is for logging
    $Logfile = ""

    Function Backup-VMs
    {
        [CmdletBinding(SupportsShouldProcess=$True)]
        Param(
            [parameter(Mandatory = $true)]
            [string]$BackupDriveLetter,                     # $BackupDriveLetter:\VMBackups\$backupDate

            [ValidateNotNullOrEmpty()]
            [string]$VMHost,                                        # the host that holds the vms we wish to back up, otherwise the one running the script
            [string[]]$VMNames,                                     # if not specified, back up all of them
            [switch]$ShutHostDownWhenFinished       # when set, shuts down the target host, including any vms on it
            )
        process
        {
            # first, run a bunch of checks

            # check if the .Net 4.5 is installed
            $isDotNet45Installed = Test-Net45
            if (!$isDotNet45Installed)
            {
                Write-Host -ForegroundColor Red ".Net 4.5 is not installed - terminating backup script."
                Break
            }
            # check if the HyperV module is loaded
            $isHyperVModuleLoaded = Get-Module -Name Hyper-V
            if (!$isHyperVModuleLoaded)
            {
                Write-Host "Attempting to load Hyper-V module..."
                Import-Module -Name Hyper-V
                $isHyperVModuleLoaded = Get-Module -Name Hyper-V
                if (!$isHyperVModuleLoaded)
                {
                    Write-Host -ForegroundColor Red "Cannot load Hyper-V module - terminating backup script."
                    Break
                }
            }
            # sanitize user input (F: will become F)
            if ($BackupDriveLetter -like "*:")
            {
                $BackupDriveLetter = $BackupDriveLetter -replace ".$"
            }
            # check to make sure the user specified a valid backup location
            if ((Test-Path "$($BackupDriveLetter):") -eq $false)
            {
                Write-Host -ForegroundColor Red "Drive $($BackupDriveLetter): does not exist - terminating backup script."
                Break
            }
            # if host was not speicified, use the host running the script
            if ($VMHost -eq "")
            {
                $VMHost = Hostname
            }
            # check to make sure the specified host is a vmhost
            if (!(Get-VMHost) -icontains $VMHost)
            {
                Write-Host -ForegroundColor Red "Host $($VMHost) is not listed in Get-VMHost - terminating backup script."
                Break
            }
            # check to make sure the specified host has any vms to back up
            if (!(Get-VM -ComputerName $VMHost))
            {
                Write-Host -ForegroundColor Red "Host $($VMHost) does not appear to have any VMs running on it according to 'Get-VM -ComputerName $($VMHost)'."
                Write-Host -ForegroundColor Yellow "This can be occur if PowerShell is not running with elevated privileges."
                Write-Host -ForegroundColor Yellow "Please make sure that you are running PowerShell with Administrator privileges and try again."
                Write-Host -ForegroundColor Red "Terminating backup script."
                Break
            }
            #endregion

            #region directory business
            # make our parent directory if needed
            if ((Test-Path "$($BackupDriveLetter):\VMBackup") -eq $false)
            {
                $parentDir = New-Item -Path "$($BackupDriveLetter):\VMBackup" -ItemType "directory"
                if ((Test-Path $parentDir) -eq $false)
                {
                    Write-Host -ForegroundColor Red "Problem creating $parentDir - terminating backup script."
                    Break
                }
            }

            # initialize our logfile
            $Logfile = "$($BackupDriveLetter):\VMBackup\Backup-VMs.log"
            if ((Test-Path $Logfile) -eq $false)
            {
                $newFile = New-Item -Path $Logfile -ItemType "file"
                if ((Test-Path $Logfile) -eq $false)
                {
                    Write-Host -ForegroundColor Red "Problem creating $Logfile - terminating backup script."
                    Break
                }
            }

            $backupDate = Get-Date -Format "yyyy-MM-dd"
            $destDir = "$($BackupDriveLetter):\VMBackup\$backupDate-$VMHost-backup\"

            # make our backup directory if needed
            if ((Test-Path $destDir) -eq $false)
            {
                $childDir = New-Item -Path $destDir -ItemType "directory"
                if ((Test-Path $childDir) -eq $false)
                {
                    Write-Host -ForegroundColor Red "Problem creating $childDir - terminating backup script."
                    Break
                }
            }
            #endregion

            Add-content -LiteralPath $Logfile -value "==================================================================================================="
            Add-content -LiteralPath $Logfile -value "==================================================================================================="
            # now that our checks are done, start backing up
            T -text "Starting Hyper-V virtual machine backup for host $VMHost at:"
            $dateTimeStart = date
            T -text "$($dateTimeStart)"
            T -text ""

            # export the vms to the destination
            ExportMyVms -VMHost $VMHost -Destination $destDir -VMNames $VMNames

            T -text ""
            T -text "Exporting finished"

            #region compression

            # get what we just backed up
            $sourceDirectory = Get-ChildItem $destDir

            if ($sourceDirectory)
            {
                # get the total size of all of the files we just backed up
                $sourceDirSize = Get-ChildItem $destDir -Recurse | Measure-Object -property length -sum -ErrorAction SilentlyContinue
                $sourceDirSize = ($sourceDirSize.sum / 1GB)

                # get how much free space is left on our backup drive
                $hostname = Hostname
                $backupDrive = Get-WmiObject win32_logicaldisk -ComputerName $hostname | Where-Object { $_.DeviceID -eq "$($BackupDriveLetter):" }
                $backupDriveFreeSpace = ($backupDrive.FreeSpace / 1GB)

                # tell the user what we've found
                $formattedBackupDriveFreeSpace = "{0:N2}" -f $backupDriveFreeSpace
                $formattedSourceDirSize = "{0:N2}" -f $sourceDirSize
                T -text "Checking free space for compression:"
                T -text "Drive $($BackupDriveLetter): has $formattedBackupDriveFreeSpace GB free on it, this backup took $formattedSourceDirSize GB"

                # check if we need to make any room for the next backup
                $downToOne = $false
                while (!$downToOne -and $sourceDirSize > $backupDriveFreeSpace)
                {
                    # clear out the oldest backup if this is the case
                    $backups = Get-ChildItem -Path "$($BackupDriveLetter):\VMBackup\" -include "*-backup.zip" -recurse -name
                    $backups = [array]$backups | Sort-Object

                    # make sure we aren't deleting the only directory!
                    if ($backups.length -gt 1)
                    {
                        T -text "Removing the oldest backup [$($backups[0])] to clear up some more room"
                        Remove-Item "$($BackupDriveLetter):\VMBackup\$($backups[0])" -Recurse -Force
                        # now check again
                        $backupDrive = Get-WmiObject win32_logicaldisk -ComputerName $hostname | Where-Object { $_.DeviceID -eq "$($BackupDriveLetter):" }
                        $backupDriveFreeSpace = ($backupDrive.FreeSpace / 1GB)
                        $formattedBackupDriveFreeSpace = "{0:N2}" -f $backupDriveFreeSpace
                        T -text "Now we have $formattedBackupDriveFreeSpace GB of room"
                    }
                    else
                    {
                        # we're down to just one backup left, don't delete it!
                        $downToOne = $true
                    }
                }
                T -text "Compressing the backup..."
                # zip up everything we just did
                ZipFolder -directory $destDir -VMHost $VMHost

                $zipFileName = $destDir -replace ".$"
                $zipFileName = $zipFileName + ".zip"

                T -text "Backup [$($zipFileName)] created successfully"
                $destZipFileSize = (Get-ChildItem $zipFileName).Length / 1GB
                $formattedDestSize = "{0:N2}" -f $destZipFileSize
                T -text "Uncompressed size:`t$formattedSourceDirSize GB"
                T -text "Compressed size:  `t$formattedDestSize GB"
            }
            #endregion

            # delete the non-compressed directory, leaving just the compressed one
            Remove-Item $destDir -Recurse -Force

            T -text ""
            T -text "Finished backup of $VMHost at:"
            $dateTimeEnd = date
            T -text "$($dateTimeEnd)"
            $length = ($dateTimeEnd - $dateTimeStart).TotalMinutes
            $length = "{0:N2}" -f $length
            T -text "The operation took $length minutes"

            if ($ShutHostDownWhenFinished -eq $true)
            {
                T -text "Attempting to shut down host machine $VMHost"
                ShutdownTheHost -HostToShutDown $VMHost
            }
        }
    }

    ## this function will shut down any vms running on the host executing this script and then shut down said host
    Function ShutdownTheHost
    {
        [CmdletBinding(SupportsShouldProcess=$True)]
        Param(
            [string]$HostToShutDown
            )
        process
        {
            ## Get a list of all VMs on $HostToShutDown
            $VMs = Get-VM -ComputerName $HostToShutDown
            ## only run through the list if there's anything in it
            if ($VMs)
            {
                ## For each VM on Node, Save (if necessary), Export and Restore (if necessary)
                foreach ($VM in @($VMs))
                {
                    $VMName = $VM.ElementName
                    $summofvm = get-vm -Name $VMName | select *
                    $summhb = $summofvm.heartbeat
                    $summes = $summofvm.state

                    ## Shutdown the VM if HeartBeat Service responds
                    if ($summhb -eq "OK")
                    {
                        T -text ""
                        T -text "HeartBeat Service for $VMName is responding $summhb, saving the machine state"

                        Stop-VM -VMName $VMName -ComputerName $VMHost -Force
                    }
                    ## Checks to see if the VM is already stopped
                    elseif (($summes -eq "Stopped") -or ($summes -eq "Suspended"))
                    {
                        T -text ""
                        T -text "$VMName is $summes"
                    }

                    ## If the HeartBeat service is not OK, aborting this VM
                    elseif ($summhb -ne "OK" -and $summes -ne "Stopped")
                    {
                        T -text
                        T -text "HeartBeat Service for $VMName is responding $summhb. Aborting save state."
                    }
                }
                T -text "All VMs on $HostToShutDown shut down or suspended."
            }
            T -text "Shutting down machine $HostToShutDown..."
            Stop-Computer -ComputerName $HostToShutDown
        }
    }
    
    function ZipFolder(
        [IO.DirectoryInfo] $directory)
    {    
        $backupFullName = $directory.FullName

        T -text ("Creating zip file for folder ($backupFullName)...")

        [IO.DirectoryInfo] $parentDir = $directory.Parent

        [string] $zipFileName

        If ($parentDir.FullName.EndsWith("\") -eq $true)
        {
            # e.g. $parentDir = "C:\"
            $zipFileName = $parentDir.FullName + $directory.Name + ".zip"
        }
        Else
        {
            $zipFileName = $parentDir.FullName + "\" + $directory.Name + ".zip"
        }

        Add-Type -Assembly System.IO.Compression.FileSystem
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
        [System.IO.Compression.ZipFile]::CreateFromDirectory($directory, $zipFileName, $compressionLevel, $false)

        T -text "Successfully created zip file for folder ($backupFullName)."
    }

    ## Check if .Net 4.5 is installed
    ## Taken from here http://blogs.technet.com/b/heyscriptingguy/archive/2013/11/02/powertip-find-if-computer-has-net-framework-4-5.aspx
    function Test-Net45
    {
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full')
        {
            if (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction SilentlyContinue)
            {
                return $True
            }
            return $False
        }
    }

    ## Powershell Script to Shutdown and Export Hyper-V 2008 R2 VMs, one at a time.  
    ## Written by Stan Czerno
    ## http://www.czerno.com/default.asp?inc=/html/windows/hyperv/cluster/HyperV_Export_VMs.asp
    ## I have modified his approach to suit our purposes
    Function ExportMyVms
    {
        [CmdletBinding(SupportsShouldProcess=$True)]
        Param(
            [string]$Destination,
            [string[]]$VMNames,
            [string]$VMHost
            )
        process
        {              
            ## Get a list of all VMs on Node
            if ($VMNames)
            {
                if (($VMNames.Length) -gt 1)
                {
                    # pass in a multiple-element string array directly
                    $VMs = Get-VM -Name $VMNames -ComputerName $VMHost
                }
                else
                {
                    # turn a single-element string array back into a string
                    $VMNames = [string]$VMNames
                    $VMs = Get-VM -Name "$VMNames" -ComputerName $VMHost
                }
            }
            else
            {
                $VMs = Get-VM -ComputerName $VMHost
            }

            ## only run through the list if there's anything in it
            if ($VMs)
            {
                foreach ($VM in @($VMs))
                {
                    $listOfVmNames += $VM.Name + ", "
                }
                $listOfVmNames = $listOfVmNames -replace "..$"
                T -text "Attempting to backup the following VMs:"
                T -text "$listOfVmNames"
                T -text ""
                Write-Host "Do not cancel the export process as it may cause unpredictable VM behavior" -ForegroundColor Yellow

                ## For each VM on Node, Save (if necessary), Export and Restore (if necessary)
                foreach ($VM in @($VMs))
                {
                    $VMName = $VM.Name
                    $summofvm = get-vm -Name $VMName | select *
                    $summhb = $summofvm.heartbeat
                    $summes = $summofvm.state
                    $restartWhenDone = $false

                    $doexport = "no"

                    ## Shutdown the VM if HeartBeat Service responds
                    if (($summhb -eq "OK") -or ($summhb -like "ok*"))
                    {
                        $doexport = "yes"
                        T -text ""
                        T -text "HeartBeat Service for $VMName is responding $summhb, saving the machine state"
                        $restartWhenDone = $true

                        Stop-VM -VMName $VMName -ComputerName $VMHost -Force

                        #Wait until the machine is Off
                        T -text "Waiting for shutdown operation to finish "
                        While ((Get-VM -VMName $VMName -ComputerName $VMHost).State -ne "Off")
                        {
                            Write-Host "." -NoNewLine
                            Start-Sleep -Seconds 5
                        }
                    }
                    ## Checks to see if the VM is already stopped
                    elseif (($summes -eq "Stopped") -or ($summes -eq "Suspended") -or ($summes -eq "Off"))
                    {
                        $doexport = "yes"
                        T -text ""
                        T -text "$VMName is $summes, starting export"
                    }

                    ## If the HeartBeat service is not OK, aborting this VM
                    elseif ($summhb -ne "OK" -and $summes -ne "Stopped")
                    {
                        $doexport = "no"
                        T -text ""
                        T -text "HeartBeat Service for $VMName is responding $summhb. Save state and export aborted for $VMName"
                    }

                    if ($doexport -eq "yes")
                    {
                        $VMEnabledState = (Get-VM -VMName $VMName -ComputerName $VMHost).State
                        T -text $VMEnabledState
                        if (("Suspended", "Stopped", "Off") -contains $VMEnabledState)
                        {
                            ## If a folder already exists for the current VM, delete it.
                            if ([IO.Directory]::Exists("$($Destination)\$($VMName)"))
                            {
                                [IO.Directory]::Delete("$($Destination)\$($VMName)", $True)
                            }
                            T -text "Exporting $VMName"

                            ## Begin export of the VM
                            export-vm -Name $VMName -ComputerName $VMHost -path $Destination -ErrorAction SilentlyContinue

                            ## check to ensure the export succeeded
                            $exportedCount = (Get-ChildItem $Destination -Force -Recurse).Count

                            ## there should be way more than 5 elements in the destination - this is to account for empty folders
                            if ($exportedCount -lt 5)
                            {
                                T -text "***** Automated export failed for $VMName *****"
                                T -text "***** Manual export advised *****"
                            }

                            if ($restartWhenDone)
                            {
                                T -text "Restarting $VMName..."

                                ## Start the VM and wait for a Heartbeat with a 5 minute time-out
                                Start-VM $VMName -HeartBeatTimeOut 300 -Wait
                            }
                        }
                        else
                        {
                            T -text "Could not properly save state on VM $VMName, skipping this one and moving on."
                        }
                    }
                }
            }
            else
            {
                T -text "No VMs found to back up."
            }
        }
    }

    ## This is just a hand-made wrapper function that mimics the Tee-Object cmdlet with less fuss
    ## Plus, it makes our log file prettier
    Function T
    {
        [CmdletBinding(SupportsShouldProcess=$True)]
        Param(
            [string]$text
            )
        process
        {
            Write-Host "$text"
            $now = date
            $text = "$now`t: $text"
            Add-content -LiteralPath $Logfile -value $text
        }
    }
