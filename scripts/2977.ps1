function get-DiskVolumeInfo
{
    <#
        .SYNOPSIS
        Returns information about disk volumes including freespace
        
        .DESCRIPTION
        Returns information about disk volumes including freespace
        
        .EXAMPLE
        show-InnerException ExceptionObject
        Shows the inner exception object of the error object that is passed to the
        function.
        
        .Notes
    	ChangeLog    :
    	Date	    Initials	Short Description
        02/18/2009  RLV         New
 
        .Link
        http://msdn.microsoft.com/en-us/library/aa394239(v=VS.85).aspx
        
        .Link
        http://msdn.microsoft.com/en-us/library/aa394515(VS.85).aspx
        
        .Link
        http://msdn.microsoft.com/en-us/library/windows/desktop/aa394173(v=vs.85).aspx
    #>

    [CmdletBinding()]
    param
        (
            [Parameter(Mandatory=$true)][string]$ComputerName,
            [Parameter(Mandatory=$false)][switch]$Raw
        )
        
    trap 
    {
        show-InnerException -ex $_
        continue
    }

    write-verbose "$($MyInvocation.InvocationName) - Begin function"
    foreach($Key in $PSBoundParameters.Keys){ write-verbose "$($MyInvocation.InvocationName) PARAM: -$Key - $($PSBoundParameters[$Key])" }

    # Create an empty array to hold the property bags that will be created later
    $VolArray = @()
    
    # Windows 2003 supports mount points
    if($(gwmi win32_operatingSystem -comp $ComputerName).version -ge '5.2')
    {
        # #region Persistent fold region
        $VolArray = gwmi win32_volume -Computer $ComputerName | Select-Object `
            @{Name='Computer';Expression={$ComputerName}}, `
            @{Name='VolumeName';Expression={if($_.Name -like "\\?\Volume*"){'\\?\Volume'}else{$_.Name}}}, `
            @{Name='Capacity_GB';Expression={[math]::Round($_.Capacity/1GB)}}, `
            @{Name='FreeSpace_GB';Expression={[math]::Round($_.FreeSpace/1GB)}}, `
            @{Name='Pct_Free';Expression={if($_.Capacity -gt 0){[math]::Round(($_.FreeSpace/$_.Capacity)*100)}else{0}}}, `
            @{Name='BlockSize_KB';Expression={[math]::Round($_.Blocksize/1KB)}}
        # #endregion
    }
    else
    # Windows 2000 and Windows XP no mount point support
    {
        # #region Persistent fold region
        $VolArray = gwmi win32_LogicalDisk -Computer $ComputerName | Select-Object `
            @{Name='Computer';Expression={$ComputerName}}, `
            @{Name='VolumeName';Expression={$_.Name}}, `
            @{Name='Capacity_GB';Expression={[math]::Round($_.Size/1GB)}}, `
            @{Name='FreeSpace_GB';Expression={[math]::Round($_.FreeSpace/1GB)}}, `
            @{Name='Pct_Free';Expression={if($_.Size -gt 0){[math]::Round(($_.FreeSpace/$_.Size)*100)}else{0}}}
        # #endregion
   }
    
    if($Raw){  $VolArray   }
    else{   $VolArray | ft -auto    }
    
    write-verbose "$($MyInvocation.InvocationName) - End function"
}
