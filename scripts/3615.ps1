#Examples

<#
New-XVM -Name "WS2012-TestServer01" -SwitchName "Switch(192.168.2.0/24)" -VhdType NoVHD
New-XVM -Name "WS2012-TestServer02" -SwitchName "Switch(192.168.2.0/24)" -VhdType ExistingVHD -VhdPath 'D:\vhds\WS2012-TestServer02.vhdx'
New-XVM -Name "WS2012-TestServer03" -SwitchName "Switch(192.168.2.0/24)" -VhdType NewVHD
New-XVM -Name "WS2012-TestServer04" -SwitchName "Switch(192.168.2.0/24)" -VhdType NewVHD -DiskType Fixed -DiskSize 1GB
New-XVM -Name "WS2012-TestServer05" -SwitchName "Switch(192.168.2.0/24)" -VhdType NewVHD -DiskType Dynamic
New-XVM -Name "WS2012-TestServer06" -SwitchName "Switch(192.168.2.0/24)" -VhdType Differencing -ParentVhdPath 'D:\vhds\Windows Server 2012 RC Base.vhdx'
New-XVM -Name "WS2012-TestServer07" -SwitchName "Switch(192.168.2.0/24)" -VhdType NewVHD -Configuration @{"MemoryStartupBytes"=1GB;"BootDevice"="LegacyNetworkAdapter"}
#>

Function New-XVM
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory=$false,Position=1)]
        [string]$ComputerName=$env:COMPUTERNAME,        
        [Parameter(Mandatory=$true,Position=2)]
        [string]$Name,
        [Parameter(Mandatory=$true,Position=3)]
        [string]$SwitchName,
        [Parameter(Mandatory=$true,Position=4)]
        [ValidateSet("NoVHD","ExistingVHD","NewVHD","Differencing")]
        [string]$VhdType,
        [Parameter(Mandatory=$false,Position=5)]
        [hashtable]$Configuration
    )
    DynamicParam
    {
        Switch ($VhdType) {
            "ExistingVHD" {
                $attributes = New-Object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "_AllParameterSets"
                $attributes.Mandatory = $true
                $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $vhdPath = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("VhdPath", [String], $attributeCollection)
                $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("VhdPath",$vhdPath)
                return $paramDictionary
            }
            "NewVHD" {
                $attributes = New-Object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "_AllParameterSets"
                $attributes.Mandatory = $false
                $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $diskType = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("DiskType", [String], $attributeCollection)
                $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("DiskType",$diskType)
                $attributes = New-Object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "_AllParameterSets"
                $attributes.Mandatory = $false
                $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $diskSize = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("DiskSize", [uint64], $attributeCollection)
                $paramDictionary.Add("DiskSize",$diskSize)
                return $paramDictionary
            }
            "Differencing" {
                $attributes = New-Object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "_AllParameterSets"
                $attributes.Mandatory = $true
                $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)
                $parentVhdPath = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("ParentVhdPath", [String], $attributeCollection)
                $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("ParentVhdPath",$parentVhdPath)
                return $paramDictionary
            }
        }
    }
    Begin
    {
        Try
        {
            $vmHost = Get-VMHost -ComputerName $ComputerName -ErrorAction:Stop
        }
        Catch
        {
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
        $defaultVirtualHardDiskPath = $vmHost.VirtualHardDiskPath
    }
    Process
    {
        $validConfigNames = "MemoryStartupBytes","BootDevice"
        $configParams = @()
        Switch ($VhdType) {
            "NoVHD" {
                $newVhdPath = $null
            }
            "ExistingVHD" {
                $newVhdPath = $vhdPath.Value
            }
            "NewVhd" {
                if (-not $diskType.IsSet) {$diskType.Value = "Dynamic"}
                if (-not $diskSize.IsSet) {$diskSize.Value = 127GB}
                $newVhdPath = Join-Path -Path $defaultVirtualHardDiskPath -ChildPath "$Name.vhdx"
                Switch ($diskType.Value) {
                    "Fixed" {
                        $vhdFile = New-VHD -Fixed -SizeBytes $diskSize.Value -Path $newVhdPath -ErrorAction Stop
                    }
                    "Dynamic" {
                        $vhdFile = New-VHD -Dynamic -SizeBytes $diskSize.Value -Path $newVhdPath -ErrorAction Stop
                    }
                }
            }
            "Differencing" {
                $newVhdPath = Join-Path -Path $defaultVirtualHardDiskPath -ChildPath "$Name.vhdx"
                $vhdFile = New-VHD -Differencing -ParentPath $parentVhdPath.Value -Path $newVhdPath -ErrorAction Stop
            }
        }
        if ($vhdFile -ne $null) {
            Try
            {
                $command = "New-VM -ComputerName $ComputerName -Name '$Name' -SwitchName '$SwitchName' -VHDPath '$($vhdFile.Path)'"
            }
            Catch
            {
                $PSCmdlet.WriteError($Error[0])
                Remove-Item -Path $vhdFile.Path
            }
        } else {
            $command = "New-VM -ComputerName $ComputerName -Name '$Name' -SwitchName '$SwitchName' -NoVHD"
        }
        if ($Configuration -ne $null) {
            foreach ($configName in $Configuration.Keys.GetEnumerator()) {
                if ($validConfigNames -contains $configName) {
                    $configParams += "-$configName" + " " + $Configuration[$configName]
                }
            }
            $configParams = $configParams -join " "
        }
        if ($configParams.Count -eq 0) {
            $command += " -ErrorAction Stop"
        } else {
            $command += " $configParams -ErrorAction Stop"        
        }
        Invoke-Expression -Command $command
    }
    End {}
}
