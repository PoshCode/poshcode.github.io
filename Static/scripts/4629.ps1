function Set-JavaPropertyFileValue($propFile, $propName, $propValue){

	[string]$finalFile=""
	
	if (test-path $propFile){
		write-verbose "Found property file $propFile"
		write-verbose "Read propfile"
		$file = gc $propfile
		
		foreach($line in $file){
			if ((!($line.StartsWith('#'))) -and
				(!($line.StartsWith(';'))) -and
				(!($line.StartsWith(";"))) -and
				(!($line.StartsWith('`'))) -and
				(($line.Contains('=')))){
				
				write-verbose "Searching for: $propName"
				$property=$line.split('=')[0]
				write-verbose "Looking: $property" 
					#split line, left side if propName right side is value
					
					if ($propName -eq $property){
						write-verbose "found property name"
						$line="$propName=$propValue"
					}
				}
			$finalFile+="$line`n"
		}
		
		$finalFile | out-file "$propFile" -encoding "ASCII"
		
	}else
	{
		write-error "Java Property file: $propFile not found"
	}
}
