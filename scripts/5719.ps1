function Get-ScriptDC
{

    <#
    .SYNOPSIS
    This function verifies that the specified DC is online, and returns
    another one if it's not.

    .DESCRIPTION
    This function verifies that the specified DC is online, and if it isn't,
    all the other DCs in the same site as the executing PowerShell session
    will be retrieved and checked if they are online.

    The first working DC will be returned as a string.

    .EXAMPLE
    Get-ScriptDC -PreferedDC MyDomainController.contoso.com

    #>

    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$True)]
    [string] $PreferedDC)

    $ActiveDirectoryServer = $PreferedDC

    $ServerADSite = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name

    try {
        $ActiveDirectoryBackupServers = Get-ADDomainController -Filter * -ErrorAction Stop | Where-Object { $_.Site -eq $ServerADSite } -ErrorAction Stop | select -ExpandProperty HostName -ErrorAction Stop | Where-Object { $_ -ne $ActiveDirectoryServer } -ErrorAction Stop
    }
    catch {
        Write-Error "AD comunication failed! Aborting script."
        return; 
    }


    Remove-Variable ADAlive -ErrorAction SilentlyContinue

    try {
        $ADAlive = Get-ADDomain -Server $ActiveDirectoryServer -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to connect to $ActiveDirectoryServer."

        foreach ($ActiveDirectoryBackupServer in $ActiveDirectoryBackupServers) {
            Remove-Variable ADAlive -ErrorAction SilentlyContinue

            try {
                $ADAlive = Get-ADDomain -Server $ActiveDirectoryBackupServer -ErrorAction Stop
            }
            catch {
                Write-Warning "Failed to connect to $ActiveDirectoryBackupServer aswell..."
            }

            if ($ADAlive -ne $null) {
                $ActiveDirectoryServer = $ActiveDirectoryBackupServer
                break;
            }
        }

        if ($ADAlive -eq $null) {
            Write-Error "AD comunication failed! Aborting script."
            return;
        }
    }

    Write-Output $ActiveDirectoryServer
}
