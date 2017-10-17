#########################################################################
#
# Is-Prime
#
#Written by Tynen
#
#########################################################################
function Is-Prime{
	param ($number)

	if($number -is [int] -or $number -is [long] -or $number -is [double] -or $number -is [single]){
		$i = 1
		do {
			$math = $number / $i
			$i++
			if(is-natural($math)){
				$Result += @($math)
			}
		}while ($i -le $number)
	}else{return "Error: Did not receive an integer"}
	
	if($Result.Count -eq 2 -or $Result.Count -eq 1){
		return $true
	}else{return $false}
}
