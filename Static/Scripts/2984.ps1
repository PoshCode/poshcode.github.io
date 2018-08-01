function get-SQLInstanceInfo
{
    <#
        .SYNOPSIS
        get-SQLInstanceInfo
        
        .DESCRIPTION
        Retrieves the following information for each SQL Instance on the server or cluster node, and 
        returns as an array of PSCustomObjects
            DisplayName
            Name       
            Clustered  
            InstanceID 
            FileVersion
            Version    
            VirtualName
            Instance   
            Port       
            ServiceState
            ServiceAccount
            Edition       
            AuditLevel    
            LoginMode     
            PhysicalMemory
            Processors    
            Product       
            ProductLevel  
            MajorVersion  
            MinorVersion  
            Build         
            Release       
                
        .NOTES
        
    	Dependencies :  None

    	ChangeLog    :
    	Date	    Initials	Short Description
        10/04/2011  RLV         New

        .LINK
        http://technet.microsoft.com/en-us/magazine/ff458353.aspx

    #>


    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)][string]$ServerName = $(hostname)
    )

    trap 
    {
        #show-InnerException -ex $_
        $_
        break
    }

    #write-log "$($MyInvocation.InvocationName) - Begin function"
    foreach($Key in $PSBoundParameters.Keys){ write-log "$($MyInvocation.InvocationName) PARAM: -$Key - $($PSBoundParameters[$Key])" }
    

    [system.reflection.assembly]::LoadWithPartialName('Microsoft.SQLServer.SQLWMIManagement') | out-null

    $InstanceInfos = @()

    $Instances = (new-object 'microsoft.sqlserver.management.smo.Wmi.ManagedComputer' "$ServerName").Services | where-object{$_.type -eq 'SqlServer'}

    foreach($Instance in $Instances )
    {
        
        [psobject]$InstanceInfo = "" | Select-Object DisplayName, Name, Clustered, `
                                                        InstanceID, FileVersion, Version, `
                                                        VirtualName, Instance, Port, ServiceState, `
                                                        ServiceAccount, Edition, AuditLevel, LoginMode, `
                                                        PhysicalMemory, Processors, Product, ProductLevel, `
                                                        MajorVersion, MinorVersion, Build, Release
                                                    
        write-verbose "Processing SQL Instance: $($Instance.Name)"
        
        $InstanceInfo.DisplayName    = $Instance.DisplayName
        $InstanceInfo.Name           = $Instance.Name
        $InstanceInfo.Clustered      = $Instance.AdvancedProperties['CLUSTERED'].Value
        $InstanceInfo.InstanceID     = $Instance.AdvancedProperties['INSTANCEID'].Value
        $InstanceInfo.FileVersion    = $Instance.AdvancedProperties['FILEVERSION'].Value
        $InstanceInfo.Version        = $Instance.AdvancedProperties['VERSION'].Value
        if($Instance.AdvancedProperties['VSNAME'].Value -eq ''){ $InstanceInfo.VirtualName = 'N/A' }
        else { $InstanceInfo.VirtualName    = $Instance.AdvancedProperties['VSNAME'].Value }
        if($Instance.Name.Split('$')[1] -eq $Null){ [string]$InstanceName = 'MSSQLSERVER' }
        else { [string]$InstanceName = $Instance.Name.Split('$')[1] }
        $InstanceInfo.Instance       = $InstanceName
        $InstanceInfo.Port           = $Instance.Parent.ServerInstances[$InstanceName].ServerProtocols['Tcp'].IPAddresses['IPALL'].IPAddressProperties['TcpPort'].Value
        $InstanceInfo.ServiceAccount = $Instance.ServiceAccount
        $InstanceInfo.ServiceState   = $Instance.ServiceState
        
        if($InstanceInfo.Clustered){ $SQLInstanceName = "$($InstanceInfo.VirtualName),$($InstanceInfo.Port)" }
        else { $SQLInstanceName = "$ServerName,$($InstanceInfo.Port)" }
        
        write-verbose "SQL InstanceName: $SQLInstanceName"
        
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") |out-null

        $SQL = new-object "Microsoft.SQLServer.Management.SMO.Server" $SQLInstanceName

        $InstanceInfo.Edition        = $SQL.Edition
        $InstanceInfo.AuditLevel     = $SQL.AuditLevel
        $InstanceInfo.LoginMode      = $SQL.LoginMode
        $InstanceInfo.PhysicalMemory = $SQL.PhysicalMemory
        $InstanceInfo.Processors     = $SQL.Processors
        $InstanceInfo.Product        = $SQL.Product
        $InstanceInfo.ProductLevel   = $SQL.ProductLevel
        $InstanceInfo.MajorVersion   = $SQL.Version.Major
        $InstanceInfo.MinorVersion   = $SQL.Version.Minor
        $InstanceInfo.Build          = $SQL.Version.Build
        
        if($SQL.Version.Major -eq 10)
        {
            switch($SQL.Version.Minor)
            {
                0
                {
                    $InstanceInfo.Release = 'Gold'
                }
                50
                {
                    $InstanceInfo.Release = 'R2'
                }
                else
                {
                    throw "Could not convert minor version into release.  Version number $($SQL.Versioin.Minor)"
                }
            }
        } else { $InstanceInfo.Release = 'Gold' }
         
        $InstanceInfos += $InstanceInfo
        
    }

    write-verbose "Showing results"
    $InstanceInfos
}

