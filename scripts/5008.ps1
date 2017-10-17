$computerlist = Get-Content "C:\computerlist.txt"
$cred = Get-Credential

foreach ($computername in $computerlist)

    {
        Write-Host -ForegroundColor Yellow "--------------------"
        Write-Host -ForegroundColor Red $computername 
        $Service = get-Service -computername $computername -name wuauserv
        
        # if statement that stops wuauclt Service if it is running, then executes WSUS reset steps
        if ($Service.status -eq "Running")
            {
                
                Write-Host 'Windows Update Service Running: Stopping Service'
                $Service.Stop()
                $Service.WaitForStatus("Stopped")
                
                Write-Host 'Removing WSUSID Registry Key'
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername ) 
                $regKey= $reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate",$true) 
                $regKey.DeleteValue('SusClientId')
                
                Write-Host 'Starting Windows Update Service'
                $Service = get-Service -computername $computername -name wuauserv
                $Service.Start()
                $Service.WaitForStatus("Running")
        
                Write-Host 'Sending Reset Authorization, Detect, and Report Commands'
                Invoke-Command -ComputerName $computername -credential $cred {wuauclt /resetauthorization /detectnow}
                Invoke-Command -ComputerName $computername -credential $cred {wuauclt /reportnow}

                Write-Host -ForegroundColor Yellow "--------------------";
                " ";

            }

 	# if wuauclt service is already stopped, skips stopping the service and executes the WSUS reset steps
        elseif ($Service.status -eq "Stopped")
            {

                Write-Host 'Removing WSUSID Registry Key'
                $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername ) 
                $regKey= $reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate",$true) 
                $regKey.DeleteValue('SusClientId')
                
                Write-Host 'Starting Windows Update Service'
                $Service = get-Service -computername $computername -name wuauserv
                $Service.Start()
                $Service.WaitForStatus("Running")
                
        
                Invoke-Command -ComputerName $computername -credential $cred {wuauclt /resetauthorization /detectnow}
                Invoke-Command -ComputerName $computername -credential $cred {wuauclt /reportnow}

                Write-Host -ForegroundColor Yellow "--------------------";
                " ";

            }
    }
