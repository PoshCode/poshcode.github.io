Function Set-RemoteService
{
<#
	.SYNOPSIS
		Sets the state and Start Mode for a Service on Remote Machine

	.DESCRIPTION
		Uses Win32_Service to set the state and Start Mode of the Service on Remote Machine.
        Correctly traps all the WMI Return Values and logs them in an Error File

	.PARAMETER  ComputerName
	    Enter a ComputerName accepts multiple ComputerNames 

	.PARAMETER  Name
		Enter the name of the Service (Will accept WQL Keywords)
	
	.PARAMETER  DisplayName
		Enter the DisplayName of the target Service (Will accept WQL wildacard)
	
	.PARAMETER  State
		Specify the State, the state of the service on the Targetmachine will be changed to this
        Valid Values Are: Running, Stopped
	
	.PARAMETER  startupType
		Specify Service Startmode, the service on the target machine will have it's startmode changed to this. 
        Valid Values are: Auto, Disabled, and Manual
	
	.PARAMETER  ErrorFile
		Logs Error in the file specified. 
        Default ErrorFile is ServiceError.txt at the Desktop of the User running Script.
	
    .EXAMPLE
        On the local machine set the 
        
        PS C:\> Set-RemoteService -Name bits -state Running -startupType Auto

        ComputerName          ServiceName           StartMode             State                
        ------------          -----------           ---------             -----                
        DexterPC2143          BITS                  Auto                  Running              


	.EXAMPLE
        In the below example the WMI Return Code 21 (Device is not ready) is returned and that comes up as a warning 
		
        PS C:\> Set-RemoteService -Name ccmexec -state Running -startupType Auto
        WARNING: DexterPC couldn't change state to Running
        WMI Call Returned : The device is not ready" 
        
        ComputerName                          ServiceName                          StartMode                            State                               
        ------------                          -----------                          ---------                            -----                               
        DexClient1                            BITS                                 Auto                                 Stopped                             

    .EXAMPLE
        Set the bits service state & startmode on the remote machine , verbose swicth turned on

        PS C:\> Set-RemoteService -ComputerName DexClient1 -Name bits -state Running -startupType Automatic -Verbose
        VERBOSE: Starting the Function...Checking if ErrorFile exists- C:\Users\ddha002\Desktop\ServiceError.txt
        VERBOSE:  ErrorFile exists & logging time to it - C:\Users\ddha002\Desktop\ServiceError.txt
        VERBOSE: Checking if sdwvpctcs2420 is online
        VERBOSE: sdwvpctcs2420 is online

        ComputerName                          ServiceName                          StartMode                            State                               
        ------------                          -----------                          ---------                            -----                               
        DexClient1                            BITS                                 Auto                                 Running                             
        VERBOSE: Stopping the Function

    .INPUTS
        System.String[]

	.OUTPUTS
		Selected.System.Management.ManagementObject[]

	.NOTES
		
        Reused Code from : 
                
        Author - Jason Morgan
        Script - Set-ServiceStartMode [http://gallery.technet.microsoft.com/Set-ServiceStartMode-18a6e13d]
        Used the DisplayName parameter after seeing this Script 

        Author - Sitaram Pamarthi
        URL - http://techibee.com/powershell/powershell-find-services-that-failed-to-start-after-server-reboot/2036
        Used Net helpmsg to interpret WMI Return codes after this article

        Written by - DexterPOSH
        Blog Url - http://dexterposgh.blogspot.com
#>

[CmdletBinding(DefaultParameterSetName='Name')]
[OutputType([PSObject])]
param(
	[Parameter(Position=0, Mandatory=$false,
				helpmessage="Enter the ComputerNames to Chec & Fix Services on",
				ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true
				)]
	#[ValidateScript({try{[system.net.dns]::Resolve("$_")|out-null; return $true} catch { throw "could not resolve the machine name"}})]
	[String[]]
	$ComputerName=$env:COMPUTERNAME,

    [Parameter(Mandatory=$true,
                ParameterSetName="Name",
                helpmessage="Enter the Service Name (Accepts WQL wildacard)")]
    [string]$Name,

    [Parameter(Mandatory=$True, 
                ParameterSetName="DisplayName", 
                HelpMessage="Enter the DisplayName of the target Service(Accepts WQL wildacard)" )] 
    [String]$DisplayName, 

    [Parameter(Mandatory=$true,helpmessage="Enter the state of the Service to be set")]
    [ValidateSet("Running","Stopped")]
    [string]$state,

    [Parameter(Mandatory=$true,helpmessage="Enter the Startup Type of the Service to be set")]
    [ValidateSet("Automatic","Manual","Disabled")]
    [string]$startupType,


    [Parameter(Mandatory=$false,helpmessage="Enter the Startup Type of the Service to be set")]
    [string]$ErrorFile="$([System.Environment]::GetFolderPath("Desktop"))\ServiceError.txt"
	)
        BEGIN
        {
            Write-Verbose -Message "Starting the Function...Checking if ErrorFile exists- $ErrorFile"
            #CReate the Errofile ...it will log Offline machines, Machines with issues
            if (!(Test-Path -Path $ErrorFile -PathType Leaf))
            {
                Write-Verbose -Message "Creating ErrorFile & logging time to it - $ErrorFile"
                New-Item -Path $ErrorFile -ItemType file 
                Add-Content -Value "$("#"*40)$(Get-Date)$("#"*40)" -Path $ErrorFile
    
            }
            else
            {
                    Write-Verbose -Message " ErrorFile exists & logging time to it - $ErrorFile"
                Add-Content -Value "$("#"*40)$(Get-Date)$("#"*40)" -Path $ErrorFile
            }
                      
                              
        }
		PROCESS 
		{
			foreach ($computer in $computername )
			{
				Write-Verbose -Message "Checking if $Computer is online"
				if (Test-Connection -ComputerName $Computer -Count 2 -Quiet)
                {
                    Write-Verbose -message "$Computer is online"
                    #region try to set the required state and StartupType of the Service
                    try
                    {
                        #based on the Parameter Set used create the Filter
                        Switch -Exact ($PSCmdlet.ParameterSetName)
                        {
	                        "Name" {$Filter = "Name LIKE '$Name'" ; break}
                            "DisplayName"{$Filter = "Name LIKE '$DisplayName'"}

                        }

                        $service = Get-WmiObject -Class Win32_Service -ComputerName $Computer -Filter $Filter  -ErrorAction Stop
                       
                        #Check the State and set it
                        if ( $service.State -ne "$state")
                        {
                            #Set the State of the Remtoe Service
                            switch -exact ($state)
                            {
                                'Running' 
                                {
                                    $changestateaction = $service.startService()
                                    Start-Sleep -Seconds 2 #it will require some time to process action
                                    if ($changestateaction.ReturnValue -ne 0 )
                                    {
                                        $err = Invoke-Expression  "net helpmsg $($changestateaction.ReturnValue)" 
                                         Write-Warning -message  "$Computer couldn't change state to $state `nWMI Call Returned :$err" 
                                         
                                    }
                                    break
                                     
                                }
                                    
                                'Stopped' 
                                {
                                    $changestateaction = $service.stopService()
                                    Start-Sleep -Seconds 2 
                                    if ($changestateaction.ReturnValue -ne 0 )
                                    {
                                        $err = Invoke-Expression  "net helpmsg $($changestateaction.ReturnValue)" 
                                        Write-Warning -message  "$Computer couldn't change state to $state `nWMI Call Returned :$err" 
                                    }
                                    break
                                }
                                    
                            } #end switch
                        } #end if

                        #Check the StartMode and set it
                        if ($service.startMode -ne $startupType)
                        {
                            
                            #set the Start Mode of the Remote Service
                            $changemodeaction = $service.ChangeStartMode("$startupType")
                            Start-Sleep -Seconds 2
                            if ($changemodeaction.ReturnValue -ne 0 )
                            {
                                $err = Invoke-Expression  "net helpmsg $($changemodeaction.ReturnValue)" 
                                Write-Warning -message  "$Computer couldn't change startmode to $startupType `nWMI Call Returned :$err" 
                            }
                                
                        } #end if
                        
                             
                        #Write the Object to the Pipeline
                        Get-WmiObject -Class Win32_Service -ComputerName $Computer -Filter "Name='$name'" -ErrorAction Stop | Select-Object -Property @{Label="ComputerName";Expression={"$($_.__SERVER)"}},@{Label="ServiceName";Expression={$_.Name}},StartMode,State       
            
                    }#end try
                    catch
                    {
                            
                        Write-Warning -Message "$Computer :: $_.exception...logging"
                        Add-Content -Value "$computer :: $_.exception" -Path $ErrorFile
                    } #end catch

                    #endregion try to set the required state and StartupType of the Service	
                                                				
											
			}
            else
            {
                Write-Verbose -Message "$Computer is Offline..Logging"
                Add-Content -Value "$computer :: Offline" -Path $ErrorFile
            }
						
		} #end foreach ($computer in $Computername)
	}#end PROCESS
    END
    {
        Write-Verbose -Message "Stopping the Function"
         $ErrorActionPreference = 'Continue' #Setting it back, Just in case someone is running this from ISE
    }

}
