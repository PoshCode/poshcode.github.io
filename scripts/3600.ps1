#Get Domain List
$objForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$DomainList = @($objForest.Domains | Select-Object Name)
$Domains = $DomainList | foreach {$_.Name}

#get users list
$users = Get-Content U:\EMCU15FI3_USER.txt

$total = $users.count
"SAMaccountname;DisplayName;HomeDir;Domain" | Out-File -FilePath test.txt
foreach($Domain in $Domains){
	$i=0
	foreach($user in $users) {
		# serializevalue parameter is used to inly get the properties needed so variable doesn't use too much RAM.
		$b = Get-QADUser -SamAccountName $user -SizeLimit 0 -Disabled -DontUseDefaultIncludedProperties -IncludedProperties NTAccountName, DisplayName, HomeDirectory, userprincipalname -SerializeValues
		$storing = $b.sAMAccountName + ";" + $b.displayName + ";" + $b.homeDirectory + ";" +$domain
		if ($storing.StartsWith(";")) {
			}
			else{
			$storing | Out-File -FilePath test.txt -append
		}
		$storing=$null
		$b=$null
		#free up the garbage collect (empties unused variables)
		[System.GC]::Collect()
		$i++;
		Write-Progress -Activity "Searching disabled accounts in $domain" -Status "Progress:" -PercentComplete $($i*100/$total)
	}
}
