$date = ( get-date ).ToString('yyyy-MM-dd-hh-mm')

$inpath = "C:\InputDir\"

$outpath = "C:\Archive\"

$FileList = @(Get-Childitem $inpath)

# Output CSV formatted report with members properly split up and unwanted domains/users removed:
$ResultFile = [System.IO.Path]::GetTempFileName()

$ADMembersOutfile = [System.IO.Path]::GetTempFileName()

$ReportFile = "C:\EntitlementsAuditProject\$date-UserEntitlementAuditTripWireFINALresult.csv"

# Wanted Local Groups
$WantedLocals = @("Administrators","Users")

# List of unwanted users to filter out:
$BadUsers = @("(null)", "") 

# List of unwanted domains and system accounts to remove:
$BadDomains = @("NT AUTHORITY","NT SERVICE") 

# Master function that calls all other functions in order
Function Main {

	# Runs Split-Member function against Landesk output report and saves results to output file
	Parse-XMLtoCSV $ResultFile
	
	# Runs function that joins the two CSV files based on commonalities in the domain members field
	JoinCSVs $ResultFile $ADMembersOutfile $ReportFile

# Ends Main function
}

# Function used to filter out unwanted Members. Function is called by Split-Member function
Function Is-ValidMember([string] $membername) {

	# Creates array based on splitting resultant Members field data further where backslashes "\" exist 
    $parts = $membername.Split("\\")

    # Logic operators used to filter out unwanted users and domains
    $BadDomains -notcontains $parts[0] -and $BadUsers -notcontains $parts[$parts.Length - 1]
    
# Ends Is-ValidMember function
}

Function Is-ValidLocalGroup([string] $localgroupname) {

	$WantedLocals -contains $localgroupname
	
}

Function Parse-XMLtoCSV ([string] $outfile) {

	$FileList | ForEach-Object {
	
		Foreach ($file in $FileList) {

			[xml]$xml = Get-Content $inpath$file

			$xml.ReportOutput.ReportBody.ReportSection | 

			Foreach-Object { 

				$system = $_.Name
				
				$_.ReportSection | 
				
				Foreach-Object {
				
					$group = $_.name
					
					$_.ReportSection.ReportSection.ReportSection | 
					
					Foreach-Object { 
						
						$_.String | 
						
						Foreach-Object {

							If ($_."#TEXT" -ne $null) {
							
								New-Object Object |
								
								Add-Member NoteProperty "System" $system -PassThru |
								
								Add-Member NoteProperty "LocalGroup" $group -PassThru |
								
								Add-Member NoteProperty "LocalMembers" $_."#TEXT" -PassThru |
								
							}
								
						} 

					} 
						
				}

			} | Where-Object { Is-ValidMember $_.LocalMembers } | Export-Csv -NoTypeInformation $outfile

		} 

	Move-Item $inpath$file $outpath$file

	}

}

# Function that pulls AD user and group data from domain controllers and outputs the data to a temp file. Function is called by JoinCSVs function
Function GetADMembersofGroups ([string] $outfile2) {

	# Quest AD cmdlet is used here to get all Global Security groups in AD and pipes out results to next part
	Get-QADGroup -SearchRoot "DC=dsl,DC=dittdsh,DC=org" -GroupType "Security" `
	-GroupScope "Global" | 
	
	# Starts ForEach-Object loop
	ForEach-Object {
		
		# Sets up $NTAccount variable
		$NTAccount = $_.NTAccountName
		
		# Sets up $Domain variable
		$Domain = $_.Domain
		
		# Sets up GroupName variable
		$GroupName =$_.Name
		
		# Sets up CatGroupName variable which concatenates $Domain and $GroupName system strings into one string for later use
		$CatGroupName = [System.String]::Concat($Domain,$GroupName)
		
		# Quest AD cmdlet is used here to get all members of AD groups that were pulled above
		Get-QADGroupMember -Identity $NTAccount -DontUseDefaultIncludedProperties -IncludedProperties `
		"SamAccountName","Name"
	
	# Ends ForEach-Object loop, pipes results to next process and starts another ForEach-Object loop			
	} | ForEach-Object {
	
		# Variable used to equate $curr to current point in CSV array. This is necessary for processing items in a class as "$_" is not allowed
		$curr = $_
		
		# Uses New-Object to create a new class named Object and pipes results out for further processing so that properties can be added to the class
   	 	New-Object Object |

		# Adds property to Object class based on concatenated $Domain and $GroupName strings, changes column name to GlobalMembers and pipes results 
		# out for further processing "-PassThru" is necessary in order to get Add-Member to output results
		Add-Member NoteProperty "GlobalMembers" $CatGroupName -PassThru |

		# Adds property to Object class based on Name column in input file, renames to Username and pipes results out for further processing 
		# "-PassThru" is necessary in order to get Add-Member to output results
		Add-Member NoteProperty "Username" $curr.Name -PassThru |
            
		# Adds property to Object class based on SamAccountName column in input file, renames to LogonID and pipes results out for further processing 
		# "-PassThru" is necessary in order to get Add-Member to output results
		Add-Member NoteProperty "LogonID" $curr.SamAccountName -PassThru |

	# Ends Object class processing loop, sorts objects by GlobalMembers colum and exports out to another temp CSV file
  	}  | Sort-Object {$_.GlobalMembers} | Export-Csv -NoTypeInformation $outfile2

# Ends GetADMembersofGroups function
}

# Starts JoinCSVs function which joins the two temp files together based on the Domain Member columns in each file
Function JoinCSVs ([string] $infile2, [string] $infile3, [string] $outfile3) {

	# Sets up $csv1 variable to hold all of the CSV data from the first temp file
	$csv1 = Import-Csv $infile2
	
	# Calls the GetADMembersofGroups function
	GetADMembersofGroups $infile3
	
	# Sets up $csv2 variable to hold all of the CSV data from the second temp file
	$csv2 = Import-Csv $infile3
	
	# Pipes data from first temp file into ForEach-Object loop
	$csv1 | ForEach-Object { 
		
		# Variable used to equate $record to current point in CSV array. This is necessary for processing items in a class as "$_" is generally not allowed 
		$record = $_ 
		
		# Sets up $matches variable which contains contents of second temp file ran through filter grabbing all matches of Domain Groups in both files
		$matches = $csv2 | Where-Object {$_.GlobalMembers -eq $record.LocalMembers} 

		# Starts if loop to process $matches variable where there are matches between the two files. Where no match is found, process is moved to else loop
		if ($matches){ 
		
			# Pushes output of $matches variable through pipe and into a ForEach-Object loop
			$matches | ForEach-Object{ 
	
				# Uses New-Object to create a new class named Object and pipes results out for further processing so that properties can be added to the class
				New-Object Object |

				# Adds property to Object class based on Username column from 2nd file and pipes results out for further processing 
				# "-PassThru" is necessary in order to get Add-Member to output results
				Add-Member noteproperty Username $_.Username -PassThru |

		   		# Adds property to Object class based on LogonID column from 2nd file and pipes results out for further processing 
				# "-PassThru" is necessary in order to get Add-Member to output results
				Add-Member noteproperty LogonID $_.LogonID -PassThru |

				# Adds property to Object class based on LocalMembers column from 1st file and pipes results out for further processing 
				# "-PassThru" is necessary in order to get Add-Member to output results
				Add-Member noteproperty Members $record.LocalMembers -PassThru |

				# Adds property to Object class based on Localgroup column from 1st file and pipes results out for further processing 
				# "-PassThru" is necessary in order to get Add-Member to output results
				Add-Member noteproperty Localgroup $record.Localgroup -PassThru |

				# Adds property to Object class based on System column from 1st file and pipes results out for further processing 
				# "-PassThru" is necessary in order to get Add-Member to output results
				Add-Member noteproperty System $record.System -PassThru |
			
			# Ends ForEach-Object loop
			} 
		
		# Ends if loop
		} 

		# starts else loop for lines in the files that don't match
		else { 

			# Uses New-Object to create a new class named Object and pipes results out for further processing so that properties can be added to the class
			New-Object Object | 

			# Adds property to Object class for Username column and pipes out a null result as a placeholder for the CSV file 
			# "-PassThru" is necessary in order to get Add-Member to output results
			Add-Member noteproperty Username $null -PassThru |

			# Adds property to Object class for LogonID column and pipes out a null result as a placeholder for the CSV file 
			# "-PassThru" is necessary in order to get Add-Member to output results
			Add-Member noteproperty LogonID $null -PassThru |
			
			# Adds property to Object class based on LocalMembers column from first file and pipes out results
			# "-PassThru" is necessary in order to get Add-Member to output results
			Add-Member noteproperty Members $_.LocalMembers -PassThru |
			
			# Adds property to Object class based on Localgroup column from first file and pipes out results
			# "-PassThru" is necessary in order to get Add-Member to output results
			Add-Member noteproperty Localgroup $_.Localgroup -PassThru | 

			# Adds property to Object class based on System column from first file and pipes out results
			# "-PassThru" is necessary in order to get Add-Member to output results
			Add-Member noteproperty System $_.System -PassThru | 

		# Ends else loop
		} 

	# Ends ForEach-Object loop, pipes out results and exports them to the final result file
	} | Export-Csv -NoTypeInformation $outfile3 
	
	# Removes the first temp file
	Remove-Item -Force $infile2
	
	# Removes the second temp file
	Remove-Item -Force $infile3

# Ends JoinCSVs function
}

# Starts Main function, which is when the script runs completely
. Main
