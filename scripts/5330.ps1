function Remove-ViewComputer{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin vmware.vimautomation.core
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$VCenterServer,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ViewServer,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$False)]
        [pscredential]$Credential
    )

    Begin{
        If($Credential -eq $null){
            $Credential = Get-Credential -UserName "contoso\$env:USERNAME" -Message "Please enter administrator credentials for $VCenterServer`:"
        }
    }
    
    Process{
        Remove-ViewADAMEntry -ViewServer $ViewServer -ComputerName $ComputerName
        Remove-ViewComposerEntry -VCenterServer $VCenterServer -ComputerName $ComputerName -Credential $Credential
        Remove-ViewADObject -ComputerName $ComputerName
        Remove-ViewVM -VCenterServer $VCenterServer -ComputerName $ComputerName
        Remove-ViewDatastoreEntry -VCenterServer $VCenterServer -ComputerName $ComputerName
    }

    End{} 
}

function Connect-ViewADAMDatabase{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ViewServer
    )

    Begin{}
    
    Process{
        $ViewServer = $ViewServer.ToUpper()

        Try{
            Write-Verbose -Message "Trying to connect to $ViewServer ADAM database ..."
            $VDMADAMDatabase = New-PSDrive -Name $ViewServer -PSProvider ActiveDirectory -Root "OU=Servers,dc=vdi,dc=vmware,dc=int" -Server "$ViewServer.contoso.net:389" -Scope Global -ErrorAction Stop
            Write-Verbose -Message "Successfully connected to $ViewServer ADAM database."
        }
        Catch{
            Write-Warning -Message "Could not connect to $ViewServer ADAM database: $($_.Exception.Message)"
        }
    }

    End{
        If($PassThru -eq $True){
            $VDMADAMDatabase
        }
    } 
}

function Disconnect-ViewADAMDatabase{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ViewServer
    )

    Begin{}
    
    Process{
        $ViewServer = $ViewServer.ToUpper()

        Try{
            Write-Verbose -Message "Disconnecting $ViewServer ADAM database ..."
            Remove-PSDrive -Name $ViewServer -ErrorAction Stop
            Write-Verbose -Message "$ViewServer ADAM database was successfully disconnected."
        }
        Catch{
            Write-Warning -Message "A drive with the name '$ViewServer' does not exist."
        }
    }

    End{} 
}

function Remove-ViewADAMEntry{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ViewServer,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName
    )

    Begin{}
    
    Process{
        $ViewServer = $ViewServer.ToUpper()
        $ComputerName = $ComputerName.ToUpper()
        Write-Verbose -Message "Checking if $ViewServer ADAM database is connected ..."
        $PSDriveTest = Test-Path -Path "$ViewServer`:"
        
        If($PSDriveTest){
            Write-Verbose -Message "$ViewServer ADAM database is connected."
        }
        Else{
            Write-Verbose -Message "$ViewServer ADAM database is not connected. Attempting to connect ..."
            Connect-NAUViewADAMDatabase -ViewServer $ViewServer
            $PSDriveTest = Test-Path -Path "$ViewServer`:"
        } 

        If($PSDriveTest){
            Push-Location
            Write-Verbose -Message "Accessing $ViewServer ADAM database ..."
            Set-Location -Path "$ViewServer`:" -ErrorAction Stop

            Foreach($Computer in $ComputerName){
                $ADAMComputer = Get-ADObject -Filter {pae-DisplayName -like $Computer} -Properties * -ErrorAction Stop  
                
                If($ADAMComputer -ne $null){
                    Write-Verbose -Message "Trying to remove $Computer from $ViewServer ADAM database ..."
                    $ADAMComputer | Remove-ADObject -Confirm:$True
                    Write-Verbose -Message "$Computer was successfully removed from ADAM database."
                }
                ElseIf($ADAMComputer -eq $null){
                    Write-Warning -Message "$Computer was not found in ADAM database. Please check spelling and try again."
                }
            }

            Pop-Location
            Disconnect-NAUViewADAMDatabase -ViewServer $ViewServer
        }
        
        Else{
            Write-Warning -Message "Could not access $ViewServer ADAM database."
        }
    }

    End{} 
}

function Remove-ViewComposerEntry{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    #Requires -PSSnapin vmware.vimautomation.core
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$VCenterServer,
        
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$False)]
        [pscredential]$Credential
    )

    Begin{
        If($Credential -eq $null){
            $Credential = Get-Credential -UserName "contoso\$env:USERNAME" -Message "Please enter administrator credentials for $VCenterServer`:"
        }
        
        $Username = $Credential.UserName
        $Password = $Credential.GetNetworkCredential().Password
    }
    
    Process{
        $VCenterServer = $VCenterServer.ToUpper()
        $ComputerName = $ComputerName.ToUpper()
        
        Invoke-Command -ComputerName $VCenterServer -ArgumentList $VerbosePreference,$ComputerName,$Username,$Password -ScriptBlock {
            Param(
                [System.Management.Automation.ActionPreference]$VerbosePreference,
                $ComputerName,
                $Username,
                $Password
            )

            $ProcessInfo = New-Object -Typename System.Diagnostics.ProcessStartInfo
            $ProcessInfo.FileName = "C:\Program Files (x86)\VMware\VMware View Composer\SviConfig.exe"
            $ProcessInfo.RedirectStandardError = $true
            $ProcessInfo.RedirectStandardOutput = $true
            $ProcessInfo.UseShellExecute = $false
            
            Foreach($Computer in $ComputerName){
                Write-Verbose -Message "Attempting to remove $Computer from View Composer database ..."

                $ProcessInfo.Arguments = "-operation=RemoveSviClone -VmName=$Computer -AdminUser=$Username -AdminPassword=$Password -ServerUrl=https://localhost:18443/SviService/v3_0"
                $Process = New-Object -TypeName System.Diagnostics.Process
                $Process.StartInfo = $ProcessInfo
                $Process.Start() | Out-Null
                $Process.WaitForExit()
                $ProcessOutput = $Process.StandardOutput.ReadToEnd() -replace "`n"," "
                $ProcessError = $Process.StandardError.ReadToEnd() -replace "`n"," "

                If($ProcessOutput -match "error"){
                    Write-Warning -Message "$ProcessOutput"
                }
                Else{
                    Write-Verbose -Message "$ProcessOutput"
                }
            }
        }
    }

    End{} 
}

function Remove-ViewADObject{
    [CmdletBinding()]

    #Requires -Modules ActiveDirectory
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName
    )

    Begin{}
    
    Process{
        $ComputerName = $ComputerName.ToUpper()

        Foreach($Computer in $ComputerName){
            Try{
                Write-Verbose -Message "Trying to remove $Computer from Active Directory ..."
                Remove-ADComputer -Identity $Computer -Confirm:$True
                Write-Verbose -Message "$Computer was successfully removed from Active Directory."
            }
            Catch{
                Write-Warning -Message "$Computer was not found in Active Directory. Please check spelling and try again."
            }
        }
    }

    End{} 
}

function Remove-ViewVM{
    [CmdletBinding()]

    #Requires -PSSnapin vmware.vimautomation.core
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$VCenterServer,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$False)]
        [pscredential]$Credential
    )

    Begin{}
    
    Process{
        $VCenterServer = $VCenterServer.ToUpper()
        $Computername = $ComputerName.ToUpper()

        Try{
            Write-Verbose -Message "Connecting to vCenter server ..."
            
            $Params = @{
                "Server" = $VCenterServer
                "ErrorAction" = "Stop"
            }

            If($Credential -ne $null){
                $Params.Credential = $Credential
            }

            Connect-VIServer @Params *> $null
            
            Foreach($Computer in $ComputerName){
                Try{
                    Write-Verbose -Message "Retrieving $Computer from vCenter datastore ..."
                    $PowerState = (get-vm -Name $Computer -ErrorAction Stop).PowerState

                    If($PowerState -eq "PoweredOff"){
                        Try{
                            Write-Verbose -Message "Trying to remove $Computer from vCenter datastore ..."
                            Remove-VM -VM $Computer -DeletePermanently -Confirm:$True -ErrorAction Stop
                            Write-Verbose -Message "$Computer was successfully removed from vCenter datastore."
                        }
                        Catch{
                            Write-Warning -Message "$Computer could not be removed from vCenter datastore."
                        }
                    }
                    ElseIf($PowerState -eq "PoweredOn"){
                        Try{
                            Write-Verbose -Message "$Computer currently PoweredOn. Trying to set VM to PoweredOff ..."
                            Stop-VM -VM $Computer -Kill -ErrorAction Stop
                            Write-Verbose -Message "$Computer was successfully set to PoweredOff."

                            Try{
                                Write-Verbose -Message "Trying to remove $Computer from vCenter datastore ..."
                                Remove-VM -VM $Computer -DeletePermanently -Confirm:$True -ErrorAction Stop
                                Write-Verbose -Message "$Computer was successfully removed from vCenter datastore."
                            }
                            Catch{
                                Write-Warning -Message "$Computer could not be removed from vCenter datastore."
                            }
                        }
                        Catch{
                            Write-Warning -Message "Could not set $Computer to PoweredOff. Cannot remove VM while VM is PoweredOn."
                        }
                    }
                }
                Catch{
                    Write-Warning -Message "$Computer was not found in vCenter datastore. Please check spelling and try again."
                }
            }

            Disconnect-VIServer -Server $VCenterServer -Confirm:$false
        }
        
        Catch{
            Write-Warning -Message "Could not connect to VCenterServer. Please verify appropriate credentials are being used."
        }
    }

    End{} 
}

function Remove-ViewDatastoreEntry{
    [CmdletBinding()]
    
    #Requires -PSSnapin vmware.vimautomation.core
    
    Param(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$VCenterServer,

        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$True)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$False)]
        [pscredential]$Credential
    )

    Begin{}

    Process{
        $VCenterServer = $VCenterServer.ToUpper()
        $Computername = $ComputerName.ToUpper()

        Try{
            Write-Verbose -Message "Connecting to vCenter server ..."
            
            $Params = @{
                "Server" = $VCenterServer
                "ErrorAction" = "Stop"
            }

            If($Credential -ne $null){
                $Params.Credential = $Credential
            }

            Connect-VIServer @Params *> $null

            $Datastore = Get-Datastore | Select-Object -ExpandProperty DatastoreBrowserPath

            Foreach($Computer in $ComputerName){
                $DatastoreEntries = Get-ChildItem -Path "$Datastore\$Computer*"

                Foreach($Entry in $DatastoreEntries){
                    $title = "Delete datastore entry?"
                    $message = "Are you sure you want to delete the datastore folder $($Entry.Name)?"
                    $yes = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList "&Yes","Yes Action"
                    $no = New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList "&No","No Action"
                    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
                    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
                    
                    If($result = 0){
                        Try{
                            Write-Verbose -Message "Deleting $($Entry.Name) ..."
                            $Entry | Remove-Item -Recurse -Confirm:$False
                            Write-Verbose -Message "$($Entry.Name) deleted successfully."
                        }
                        Catch{
                            Write-Warning -Message "Deletion failed. $($_.Exception.Message)"
                        }
                    }
                    Else{
                        Write-verbose -Message "Deletion aborted."
                    }
                }
            }

            Disconnect-VIServer -Server $VCenterServer -Confirm:$false
        }
        
        Catch{
            Write-Warning -Message "Could not connect to VCenterServer. Please verify appropriate credentials are being used."
        }
    }

    End{}
}
