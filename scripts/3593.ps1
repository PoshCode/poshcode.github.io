function is-natural{
	param ($number)
	if($number -like "*.*" -or $number -like "*-*"){
		return $false
	}else{return $true}
}
