foreach ($DL in $DLList) {
 
    $Dmember= get-distributiongroupmember -Identity $DL.Name
 
    $Dname=$DL.name
        ## HERE IS WHERE I'M GOING CRAZY.... AT NEXT LINE....
		# Create blank array to hold managers info
		$DLManagers = @()
		# Go through each entry in ManagedBy property
		$DL.ManagedBy | ForEach {
			# Split the string and add to $DLManagers array
			$DLManagers += $_.ToString().Split("/")[0]
		}
 
    write-output "Liste : $Dname"
        write-output "Géré par :"
	# Now step through that array you created
	$DLManagers | ForEach {
			# And write each entry with Write-Output :)
			Write-Output $_
		}
        Write-Output "---------------------------------------------------------------------------------"
 
    foreach ($Member in $Dmember) {
        $MName=$Member.DisplayName
        write-output "$MName"
    }
 
    write-output "`n"
        write-output "################################# FIN DE LA LISTE #################################"
        write-output "`n"
 }
