function Get-SerialNumber {
	param([VMware.VimAutomation.Types.VMHost[]]$InputObject = $null)

	process {
		$hView = $_ | Get-View -Property Hardware
		$serviceTag =  $hView.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag" }
		$assetTag =  $hView.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "AssetTag" }
		$obj = New-Object psobject
		$obj | Add-Member -MemberType NoteProperty -Name VMHost -Value $_
		$obj | Add-Member -MemberType NoteProperty -Name ServiceTag -Value $serviceTag.IdentifierValue
		$obj | Add-Member -MemberType NoteProperty -Name AssetTag -Value $assetTag.IdentifierValue
		Write-Output $obj
	}
}

