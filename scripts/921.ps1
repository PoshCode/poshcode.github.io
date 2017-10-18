# Glenn Sizemore www . Get-Admin . com
# Requires the NetApp OnTap SDK v3.5

# Get-NaAPI
# Will return a list of ZAPI Calls that the filer supports.  Can be used
# as a poor man's Get-Command for the OnTap SDK.
#########################################################################
# Usage:
# Connect to the filler
# $Filer = 'TOASTER'
# $NetApp = New-Object NetApp.Manage.NaServer($filer,1,0)
# $NetApp.SetAdminUser(UserName,Password)
#
# Example
# Get-NaAPI -Server $NetApp
#
# Will retrieve every OnTap ZAPI request in the system
#
# Example
# Get-NaAPI -NaServer $NetApp -Name Volume
# 
# Will return every ZAPI call that pertains to volume management.
Function Get-NaAPI {
    Param(
        [NetApp.Manage.NaServer]$NaServer,
        [string]$Name
    )
    Begin {
        $APIList = @()
    }
    Process {
        $NaElement = New-Object Netapp.Manage.NaElement("system-api-list")
        $apis = $NaServer.InvokeElem($naelement).GetChildByName("apis")
        Foreach ($api in $apis.GetChildren()) {
           $APIList +=  $api.getchildcontent("name")
        }
    }
    End {
        if ($Name) {
           return $APIList | Where-Object {$_ -match $name}
        } else {
            return $APIList
        }
    }
}

# Get-NaAPIElements
# Given a ZAPI call return the parameters in that call.
#########################################################################
# Usage:
# Connect to the filler
# $Filer = 'TOASTER'
# $NetApp = New-Object NetApp.Manage.NaServer($filer,1,0)
# $NetApp.SetAdminUser(UserName,Password)
#
# Example
# Get-NaAPIElements -NaServer $NaServer -API "volume-list-info"
#
# returns all the elements/parameters used by the volume-list-info API.
#
# Example
# Get-NaAPIElements -NaServer $NaServer -API "volume-list-info" -output
#
# Will return any output elements volume-list-info generates.
Function Get-NaAPIElements {
    Param(
        [NetApp.Manage.NaServer]$NaServer,
        [string[]]$API,
        [switch]$Output
    )
    Process {
        $e = New-Object NetApp.Manage.NaElement("api-list")
        Foreach ($A in $API) {
            $e.AddNewChild('api-list-info',$A)
        }
        $NaElement = New-Object NetApp.Manage.NaElement("system-api-get-elements")
        $NaElement.AddChildElement($e)
        $apilist = $NaServer.InvokeElem($naelement).getchildbyname("api-entries")
        Foreach ($A in $apiList.getchildbyname("system-api-entry-info")) {
            $Obj = "" | Select API, ElementName, ElementType, Optional, AllowNull 
            $N = $A.GetChildContent("name")
            foreach ($e in $a.getchildbyname("api-elements").getchildren()) {
                $obj.API = $N
                $obj.ElementName = $e.getchildcontent('name')
                
                switch ($e.getchildcontent('type')) {
                    "string"  {$obj.ElementType = "String"}
                    "integer" {$obj.ElementType = "int"}
                    "boolean" {$obj.ElementType = "Bool"}
                    Default   {
                        $obj.ElementType = $_
                        $objElem = $true
                        }
                }    
                
                IF (!$e.getchildbyname('is-optional')) {
                   $Obj.Optional = $False
                } Else {
                   $Obj.Optional = $true
                }
                IF (!$e.getchildbyname('is-output')) {
                   $objOutput = $False
                } Else {
                   $objOutput = $true
                }
                IF (!$e.getchildbyname('is-optional')) {
                   $Obj.Optional = $False
                } Else {
                   $Obj.Optional = $true
                }
                IF (
                    (!$e.getchildbyname('is-nonempty')) -or `
                    $e.GetChildContent('is-nonempty') -match "false"
                   ) {
                   $Obj.AllowNull = $True
                } Else {
                   $Obj.AllowNull = $False
                }
                
                Switch ($objOutput) {
                    {($Output -eq $true) -and ($_ -eq $true)}
                        {write-output $obj}
                    {($Output -eq $false) -and ($_ -eq $false)}
                        {write-output $obj}
                }
            }
        }
    }
}

# Get-NaType
# The OnTap API only supports three primitive types Int, String, and Bool.
# It also has over 80 NaTypes; NaTypes are similar to PSObjects in that 
# there is no formal class.  They are build on the fly, this function
# returns what is required to construct a new NaElement as the given Natype.
#########################################################################
# Usage:
# Connect to the filler
# $Filer = 'TOASTER'
# $NetApp = New-Object NetApp.Manage.NaServer($filer,1,0)
# $NetApp.SetAdminUser(UserName,Password)
#
# Example
# Get-NaType -NaServer $NaServer -Type "volume-info"
#
# Will return all the elements that comprise a volume-info NaElement type.
Function Get-NaType {
    Param(
        [NetApp.Manage.NaServer]$NaServer,
        [string]$Type
    )
    process {
        $NaElement = New-Object NetApp.Manage.NaElement("system-api-list-types")
        $results = $NaServer.InvokeElem($NaElement).GetChildByName("type-entries").getchildren()  
        If ($type) {
            $results = $results | ?{$_.GetChildContent("name") -eq $type}
        }
        $results.GetChildByName("type-elements").getchildren() | Select @{
                    n='name'
                    E={$_.GetChildContent("name")}
                }, @{
                    n='type'
                    E={$_.GetChildContent("type")}
                }, @{
                    n='optional'
                    E={$_.GetChildContent("is-optional")}
                }

    }
    
}
