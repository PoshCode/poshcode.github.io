function get-ContentFromString{
	param(
		[Parameter(Mandatory=$True,Position=0)]
		[string]$inputstring, 
		[switch]$recurseDir = $false
	)
	
	$directory = test-path $inputstring -PathType Container
	if($directory){
		try{
			if($recurseDir){
				$returnItem = gci $inputString -ErrorAction 'stop' -Recurse
			}else{
				$returnItem = gci $inputString -ErrorAction 'stop' 	
			}
		}catch{
			$returnItem = Read-Host "Enter valid base directory to your desired items: $inputstring was invalid"
		}finally{
			if([string]::IsNullOrEmpty($returnItem)){
				if($recurseDir){
					$returnItem = gci $inputString -ErrorAction 'stop' -Recurse
				}else{
					$returnItem = gci $inputString -ErrorAction 'stop' 	
				}
			}
			if([string]::IsNullOrEmpty($returnItem)){read-host "Cannot find base Directory, press enter to exit" ; break}
		}
	}else{
		if($inputString -like "*.csv"){
			try{
				$returnItem = Import-Csv $inputString -ErrorAction 'stop'
			}catch{
				$returnItem = Read-Host "Enter valid base directory to your CSV: $inputstring was invalid"
			}finally{
				if([string]::IsNullOrEmpty($returnItem)){
						$returnItem = Import-Csv $inputString -ErrorAction 'stop'
				}
				if([string]::IsNullOrEmpty($returnItem)){read-host "Cannot find base Directory, press enter to exit" ; break}
			}
		}else{
			try{
				$returnItem = gc $inputString -ErrorAction 'stop'
			}catch{
				$returnItem = Read-Host "Enter valid location to the txt or logfile: $inputstring was invalid"
			}finally{
				if([string]::IsNullOrEmpty($returnItem)){
						$returnItem = gc $inputString -ErrorAction 'stop'
				}
				if([string]::IsNullOrEmpty($returnItem)){read-host "Cannot find txt or logfile, press enter to exit" ; break}
			}	
		}
	}
	return $returnItem
}

