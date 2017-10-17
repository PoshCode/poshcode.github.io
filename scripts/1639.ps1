function Get-MountPointInfo {
    <#
    .Synopsis
        Get mount point volume free space information
    .Parameter Name
        Name of the system to query
    .Parameter Credential
        The Credentals to use when adding the system
    .Example
        Get-MountPointInfo -Name "Server1","Server2" -Credential (Get-Credential)
    #>
    [CmdletBinding()]
	param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$TRUE)]
        [string[]]
        $Name,
        
        [parameter(Mandatory=$false)]
		[System.Management.Automation.PSCredential]
        $Credential
    )
    Process 
    {
        If ($Credential) 
        {
             Get-WmiObject -Class Win32_MountPoint -ComputerName $name -Credential Credential|
                 Where-Object {$_.Directory -like ‘Win32_Directory.Name="D:\\MDBDATA*"’} |
                 ForEach-Object {
                    $vol = $_.Volume
                    Get-WmiObject -Class Win32_Volume -ComputerName $_.__SERVER -Credential Credential | 
                        Where-Object {$_.__RELPATH -eq $vol} | 
                            Select-object @{
                                Name="Folder"
                                Expression={$_.Caption}
                            },@{
                                Name="Server"
                                Expression={$_.SystemName}
                            },@{
                                Name="Size"
                                Expression={"{0:F3}" -f $($_.Capacity / 1GB)}
                            },@{
                                Name="Free"
                                Expression={"{0:F3}" -f $($_.FreeSpace / 1GB)}
                            },@{
                                Name="% Free"
                                Expression={"{0:F2}" -f $(($_.FreeSpace/$_.Capacity)*100)}
                            }
                }  
        }
        Else
        {
            Get-WmiObject -Class Win32_MountPoint -ComputerName $name |
                 Where-Object {$_.Directory -like ‘Win32_Directory.Name="D:\\MDBDATA*"’} |
                 ForEach-Object {
                    $vol = $_.Volume
                    Get-WmiObject -Class Win32_Volume -ComputerName $_.__SERVER| 
                        Where-Object {$_.__RELPATH -eq $vol} | 
                            Select-object @{
                                Name="Folder"
                                Expression={$_.Caption}
                            },@{
                                Name="Server"
                                Expression={$_.SystemName}
                            },@{
                                Name="Size"
                                Expression={"{0:F3}" -f $($_.Capacity / 1GB)}
                            },@{
                                Name="Free"
                                Expression={"{0:F3}" -f $($_.FreeSpace / 1GB)}
                            },@{
                                Name="% Free"
                                Expression={"{0:F2}" -f $(($_.FreeSpace/$_.Capacity)*100)}
                            }
                }
        }
    }
}
