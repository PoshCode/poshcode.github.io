##############################################################################
##
## Get-RemoteRegistryKeyProperty
##
## From Windows PowerShell Cookbook (O'Reilly)
## by Lee Holmes (http://www.leeholmes.com/guide)
##
## Updated to support 64-bit or 32-bit views
## by Burt Harris
##
##############################################################################

<#

.SYNOPSIS

Get the value of a remote registry key property

.EXAMPLE

PS >$registryPath =
     "HKLM:\software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
PS >Get-RemoteRegistryKeyProperty LEE-DESK $registryPath ExecutionPolicy

.EXAMPLE

    # Retrieves 64-bit OS registry information, even if run from 32-bit powershell
    Get-RemoteRegistryKeyProperty Delta 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -View Registry64

    # Retrieves 32-bit OS registry information, even if run from 64-bit powershell
    Get-RemoteRegistryKeyProperty Delta 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -View Registry32

#>

param(
    ## The computer that you wish to connect to
    [Parameter(Mandatory = $true)]
    $ComputerName,

    ## The path to the registry item to retrieve
    [Parameter(Mandatory = $true)]
    $Path,

    ## The specific property to retrieve
    $Property = "*",

    ## Override registry architecture view with either Registry64 or Registry32
    [Microsoft.Win32.RegistryView]$View = 'Default'
)

Set-StrictMode -Version Latest

## Validate and extract out the registry key
if($path -match "^HKLM:\\(.*)")
{
    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(
        "LocalMachine", $computername, $view)
}
elseif($path -match "^HKCU:\\(.*)")
{
    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(
        "CurrentUser", $computername, $view)
}
else
{
    Write-Error ("Please specify a fully-qualified registry path " +
        "(i.e.: HKLM:\Software) of the registry key to open.")
    return
}

## Open the key
$key = $baseKey.OpenSubKey($matches[1])
$returnObject = New-Object PsObject

## Go through each of the properties in the key
foreach($keyProperty in $key.GetValueNames())
{
    ## If the property matches the search term, add it as a
    ## property to the output
    if($keyProperty -like $property)
    {
        $returnObject |
            Add-Member NoteProperty $keyProperty $key.GetValue($keyProperty)
    }
}

## Return the resulting object
$returnObject

## Close the key and base keys
$key.Close()
$baseKey.Close()
