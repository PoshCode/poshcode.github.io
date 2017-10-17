# Convert from one device ID format to another.
function Get-DeviceIDFromMP {
    
    param([Parameter(Mandatory=$true)][string] $VolumeString,
          [Parameter(Mandatory=$true)][string] $Directory)
    
    if ($VolumeString -imatch '^\s*Win32_Volume\.DeviceID="([^"]+)"\s*$') {
        # Return it in the wanted format.
        $Matches[1] -replace '\\{2}', '\'
    }
    else {
        # Return a presumably unique hashtable key if there's no match.
        "Unknown device ID for " + $Directory
    }
    
}

function Get-MountPointData {
    
    param([Parameter(Mandatory=$true)][string[]] $ComputerName,
          #[switch] $DoNotExcludeDefaults,
          [switch] $IncludeRootDrives
          )
    
    foreach ($Computer in $ComputerName) {
        
        try {
            
            # Collect mount point device IDs and populate a hashtable with IDs as keys
            $MountPointData = @{}
            Get-WmiObject Win32_MountPoint -ComputerName $Computer | 
                Where { if ($IncludeRootDrives) { $true } else { $_.Directory -NotMatch '^\s*Win32_Directory\.Name="[a-z]:\\{2}"\s*$' } } | ForEach-Object {
                    $MountPointData.(Get-DeviceIDFromMP $_.Volume $_.Directory) = $_.Directory
            }
            
            $Volumes = Get-WmiObject Win32_Volume -ComputerName $Computer | Where {
                    if ($IncludeRootDrives) { $true } else { -not $_.DriveLetter }
                } | 
                Select-Object Label, Caption, Capacity, FreeSpace, FileSystem, DeviceID, @{n='Computer';e={$Computer}}
            
        }
        
        catch {
            
            Write-Host -Fore Red "Terminating WMI error for ${Computer} (skipping): $($Error[0])"
            continue
            
        }
        
        if (-not $Volumes) {
            Write-Host -Fore Red "No mount points found on $Computer. Skipping..."
            continue
        }
        
        $Volumes | ForEach-Object {
            
            if ($MountPointData.ContainsKey($_.DeviceID)) {
                
                if ($_.Capacity) { $PercentFree = $_.FreeSpace*100/$_.Capacity }
                else { $PercentFree = 0 }
                
                $_ | Select-Object Computer, Label, Caption, FileSystem, @{n='Size (GB)';e={$_.Capacity/1GB}},
                    @{n='Free space';e={($_.FreeSpace/1GB).ToString('N')}}, @{n='Percent free';e={$PercentFree}}
                
            }
            
        } | Sort-Object -Property 'Percent free', @{Descending=$true;e={$_.'Size (GB)'}}, Label, Caption |
            Select-Object Computer, Label, Caption, FileSystem, @{n='Size (GB)';e={$_.'Size (GB)'.ToString('N')}},
                          'Free space', @{n='Percent free';e={$_.'Percent free'.ToString('N')}}
        
    }
    
}

