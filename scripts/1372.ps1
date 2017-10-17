function Get-vCenterRetentionPolicy {
	$settings = get-view -id OptionManager-VpxSettings
	if ($settings) {
		$maxAge = ($settings.Setting | where { $_.Key -eq "task.maxAge" }).Value
		$maxAgeEnabled = ($settings.Setting | where { $_.Key -eq "task.maxAgeEnabled" }).Value

		$obj = New-Object -TypeName PSObject
		$obj | Add-Member -MemberType NoteProperty -Name "MaxAge (Days)" -Value $maxAge
		$obj | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $maxAgeEnabled
		Write-Output $obj
	}
}

