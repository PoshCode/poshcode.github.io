function Get-PermissionGroup{
    <#
    .SYNOPSIS
    Returns all permission groups from the server.
    #>
    [cmdletbinding()]
    param(
        #The user name used to login to the EFT server.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        #The password that goes with the username.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,

        #Specifies an alternate admin port on the EFT server. Default is 1100.
        [ValidateRange(0, 2147483647)]
        [int]$AdminPort = 1100,

        #The computer that is running the EFT server. Default is localhost.
        [string]$ComputerName=$env:COMPUTERNAME,

        #The site ID you want to connect to. Default is 0.
        [int]$SiteID=0
    )

    try{
        Write-Debug "Create COM Object"
        $Server = New-Object -ComObject 'SFTPCOMInterface.CIServer' -ErrorAction Stop

        Write-Debug "Connect to $ComputerName"
        $Server.Connect($ComputerName, $AdminPort, $Username, $Password)

        Write-Debug "Connect to site where SiteID = $SiteID"
        $Sites = $Server.Sites()
        $Site = $Sites.Item($SiteID)

        Write-Debug "Get current permission groups from $($Site.Name)"
        Write-Verbose "Getting the permission groups from $($Site.name)"
        Write-Output $Site.GetPermissionGroups()

        Write-Debug "Close the connection"
        $Server.Close()
    }
    catch [System.Management.Automation.MethodInvocationException]{
        Write-Error "There was an error with either the UserName, Password, ComputerName, AdminPort, or the SiteID because $($Error[0].Exception.Message)"
        return $false
    }
    catch [System.Management.Automation.PSArgumentException]{
        Write-Error "Unable to create the SFTPCOMInterface.CIServer class because $($Error[0].Exception.Message)"
        return $false
    }
    catch{
        Write-Error "Unable to get groups because $($Error[0].Exception.Message)"
        return $false
    }

}

function Create-PermissionsGroup{
    <#
    .SYNOPSIS
    Creates a new group on an EFT server.

    .DESCRIPTION
    The command the COM object SFTPCOMInterface.CIServer to apply it's methods and properties. The command returns true if it succesful and false if not.

    .EXAMPLE
    Create-PermissionsGroup -Username 'admin' -Password 'XxXxXxXxX' -GroupName 'client'

    Creates the permission group 'client' using the default port and site id. This command would have to run on the eft server.

    .LINK
    http://help.globalscape.com/help/eft6-2/mergedProjects/gs_com_api/whnjs.htm
    http://help.globalscape.com/help/gs_com_api/whnjs.htm
    #>
    [cmdletbinding()]
    param(
        #The user name used to login to the EFT server.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        #The password that goes with the username.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,

        #Specifies an alternate admin port on the EFT server. Default is 1100.
        [ValidateRange(0, 2147483647)]
        [int]$AdminPort = 1100,

        #The computer that is running the EFT server. Default is localhost.
        [string]$ComputerName=$env:COMPUTERNAME,

        #The site ID you want to connect to. Default is 0.
        [int]$SiteID=0,

        #The name of the group you want to create.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName
    )

    try{
        Write-Debug "Create COM Object"
        $Server = New-Object -ComObject 'SFTPCOMInterface.CIServer' -ErrorAction Stop

        Write-Debug "Connect to $ComputerName"
        $Server.Connect($ComputerName, $AdminPort, $Username, $Password)

        Write-Debug "Connect to site where SiteID = $SiteID"
        $Sites = $Server.Sites()
        $Site = $Sites.Item($SiteID)

        Write-Debug "Get current permission groups from $($Site.Name)"
        $CurrentGroups = $Site.GetPermissionGroups()

        Write-Debug "Compare $GroupName to current groups"
        if($CurrentGroups -contains $GroupName){
            Write-Warning "$GroupName already exists"
            Write-Debug "Close the connection"
            $Server.Close()
            return $true
        }

        Write-Debug "Create the permission group $GroupName"
        $site.CreatePermissionGroup($GroupName)

        Write-Debug "Close the connection"
        $Server.Close()

        Write-Verbose "Creating the permission group $GroupName on $($Site.name)"
        return $true
    }
    catch [System.Management.Automation.MethodInvocationException]{
        Write-Error "There was an error with either the UserName, Password, ComputerName, AdminPort, or the SiteID because $($Error[0].Exception.Message)"
        return $false
    }
    catch [System.Management.Automation.PSArgumentException]{
        Write-Error "Unable to create the SFTPCOMInterface.CIServer class because $($Error[0].Exception.Message)"
        return $false
    }
    catch{
        Write-Error "Unable to create group because $($Error[0].Exception.Message)"
        return $false
    }
}
