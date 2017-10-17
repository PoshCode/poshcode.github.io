#requires -version 3.0
function Get-OSinfoFromSCCM
{

<#
	.SYNOPSIS
		Gets the Operating System Info from the Remote Machine or SCCM Server

	.DESCRIPTION
		Retrieves the Operating System Info from the Remote Machine if it is online. Queries SCCM Server if Remote machine is offline
        One can use the -QuerySCCMOnly switch to force it to fetch the details from SCCM Server only.
        Queries Win32_OperatingSystem Class on Remote Machine and as this class is stored as part of the Hardware Inventory in  
        SMS_G_System_OPERATING_SYSTEM class on SCCM Server.
	
    .EXAMPLE
       Get-OSinfoFromSCCM -ComputerName dexterdc 


        PSComputerName  : dexterdc
        ComputerName    : dexterdc
        OS              : Microsoft Windows Server 2012 R2 Datacenter Preview
        ServicePack     : 
        LastBootupTime  : 5/23/2014 6:06:05 AM
        InstallDate     : 1/18/2014 3:29:37 PM
        OSVersion       : 6.3.9431
        SystemDirectory : C:\Windows\system32

        
        If the Machine DexterDC is online then the Script first tries to connect the Remote machine using WMI.
        Note if the SCCM Server is not specified then it won' query it.
        The Property PSComputerName tells where the information is being fetched from.

	.EXAMPLE
        Get-OSinfoFromSCCM -ComputerName dexterdc -SCCMServer DexSCCM


        PSComputerName  : dexterdc
        ComputerName    : dexterdc
        OS              : Microsoft Windows Server 2012 R2 Datacenter Preview
        ServicePack     : 
        LastBootupTime  : 5/23/2014 6:06:05 AM
        InstallDate     : 1/18/2014 3:29:37 PM
        OSVersion       : 6.3.9431
        SystemDirectory : C:\Windows\system32
        
        Just specifying SCCM Server won't make it query the SCCM Server as evident from the PSComputerName property.
        To explicitly get the info from SCCM Server use the Switch -QuerySCCMOnly (Next examle).
    
    .EXAMPLE   
            
        Get-OSinfoFromSCCM -ComputerName dexterdc -SCCMServer DexSCCM -QuerySCCMOnly


        PSComputerName  : DexSCCM
        ComputerName    : dexterdc
        OS              : Microsoft Windows Server 2012 R2 Datacenter Preview
        ServicePack     : 
        LastBootupTime  : 5/22/2014 4:24:50 PM
        InstallDate     : 1/18/2014 8:59:37 PM
        OSVersion       : 6.3.9431
        SystemDirectory : C:\Windows\system32

        Note the Property PSComputerName points to SCCM Server which means the Data is got back from SCCM Server.

         
    .INPUTS
        System.String[]

	.OUTPUTS
		PSObject[]
    
    .NOTES
	    Author - DexterPOSH
        Blog Url - http://dexterposh.blogspot.in/2014/05/powershell-sccm-2012-tip-get-os.html	
#>

[CmdletBinding()]
[OutputType([PSObject[]])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory,
                   ValuefromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName,

        #specify the SCCMServer having SMS Namespace provider installed for the site. Default is the local machine.
        [Parameter(Mandatory=$false)]
        [Alias("SMSProvider")]
        [String]$SCCMServer,

        #Specify this switch to try and query the Remote Machine before querying SCCM Server for the Info
        [Switch]$QuerySCCMOnly
    )

    BEGIN
    {
        Write-Verbose -Message "[BEGIN]"
        
        #Check if the SCCM Server supplied ..then only open CIM Session to it
        if ($PSBoundParameters.ContainsKey("SCCMServer"))
        {
            Write-Verbose -Message "SCCM Server was supplied as an argument ...trying to open a CIM Session"
           #region open a CIM session
            $CIMSessionParams = @{COmputerName = $SCCMServer;ErrorAction = 'Stop'}          
                
            try
            {
                If ((Test-WSMan -ComputerName $SCCMServer -ErrorAction SilentlyContinue).ProductVersion -match 'Stack: 3.0')
                {
                    Write-Verbose -Message "[BEGIN] WSMAN is responsive"
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol
                    Write-Verbose -Message "[BEGIN] [$CimProtocol] CIM SESSION - Opened"
                } 

                else 
                {
                    Write-Verbose -Message "[BEGIN] Attempting to connect with protocol: DCOM"
                    $CIMSessionParams.SessionOption = New-CimSessionOption -Protocol Dcom
                    $CimSession = New-CimSession @CIMSessionParams
                    $CimProtocol = $CimSession.protocol

                    Write-Verbose -Message "[BEGIN] [$CimProtocol] CIM SESSION - Opened"
                }
       

            #endregion open a CIM session

            #region create the Hash to be used later for CIM queries   
                $sccmProvider = Get-CimInstance -query "select * from SMS_ProviderLocation where ProviderForLocalSite = true" -Namespace "root\sms" -CimSession $CimSession -ErrorAction Stop
                # Split up the namespace path
                $Splits = $sccmProvider.NamespacePath -split "\\", 4
                Write-Verbose "[BEGIN] Provider is located on $($sccmProvider.Machine) in namespace $($splits[3])"
 
                # Create a new hash to be passed on later
                $hash= @{"CimSession"=$CimSession;"NameSpace"=$Splits[3];"ErrorAction"="Stop"}
                                  
            #endregion create the Hash to be used later for CIM queries
            }
            catch
            {
                Write-Warning "[BEGIN] Something went wrong"
                throw $_.Exception
            }
        }
    }
    PROCESS
    {
        foreach ($computer in $ComputerName )
        {
            try 
            {
                if ($QuerySCCMOnly)
                {
                    #If we want to only query SCCM then throw an exception here and control goes to catch block and SCCM Server will be queried
                    throw "Deliberate Exception"
                }

                #Check if machine is online 
                Test-Connection -ComputerName $ComputerName -Count 2 -Quiet -ErrorAction stop | Out-Null
                
                #using Get-WMIObject as the CIM* cmdlets require WSMAN stack 3.0 to be running on the remote machine
                $OSInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop

                
                Write-Verbose -Message "[PROCESS] Querying $computer for OSInfo"
                [pscustomobject]@{
                                    PSComputerName = $computer; #this property tells where the CIM data came from - e.g $Computer
                                    ComputerName = $computer;
                                    OS = $OSInfo.caption;
                                    ServicePack = $OSInfo.CSDVersion;
                                    LastBootupTime=$OSInfo.ConvertToDateTime($OSInfo.LastBootUpTime);
                                    InstallDate = $OSInfo.ConvertToDateTime($OSInfo.InstallDate);
                                    OSVersion = $OSInfo.Version;
                                    SystemDirectory = $OSInfo.SystemDirectory;
                                }
                
            } #end try 
            catch
            {
                if ($CimSession)
                {
                    #region machine is offline or WMI access denied then get the OSInfo from SCCM Database
                    $Query = "Select Version,CSDVersion,SystemDirectory,Installdate,LastBootuptime,installdate,caption,Description from SMS_G_System_OPERATING_SYSTEM JOIN SMS_R_System ON SMS_R_System.ResourceID = SMS_G_System_OPERATING_SYSTEM.ResourceID where SMS_R_System.NetbiosName='$computer'"
                
                    try 
                    {
                        Write-Verbose -Message "[PROCESS] Querying $SCCMServer for OSInfo"
                        $OSInfo = Get-CimInstance -Query $Query @hash
                                        
                        [pscustomobject]@{
                                            PSComputerName=$SCCMServer; #this property tells where the CIM data came from - e.g SCCM Server
                                            ComputerName=$computer;
                                            OS = $OSInfo.caption;
                                            ServicePack = $OSInfo.CSDVersion;
                                            LastBootupTime=$OSInfo.LastBootUpTime;
                                            InstallDate = $OSInfo.InstallDate;
                                            OSVersion = $OSInfo.Version;
                                            SystemDirectory = $OSInfo.SystemDirectory;
                                        }
                                            
                    
                    }
                    catch
                    {
                        Write-Warning -Message "[PROCESS} Something went wrong while querying $SCCMServer"
                        throw $Error[0].Exception
                    }
                    #endregion machine is offline get the OSInfo from SCCM Database
                }
                else
                {
                    Write-Warning -Message "[PROCESS} Something went wrong"
                    throw $_.exception 
                }
            }

        } #end foreach ($computer in $ComputerName )
    } #end Process
    END
    {
       if ($CimSession)
       {
            Write-Verbose -Message "[END] Removing the CIM Session"
            Remove-CimSession -CimSession $CimSession 
        }
        Write-Verbose -Message "[END]"
    }
}
