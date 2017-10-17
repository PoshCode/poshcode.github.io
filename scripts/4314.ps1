function Name3 {
	param(
		$Name3,
		$Name4,
		$Name5
	)
	return $Name3	
}
function Name2 {
	param(
		$Name2
	)

	return Name3 $Name2 "EMPTY" "EMPTY"
}
function Name {
	param(
		$Name
	)

	return Name2 $Name
}
$test = 'hello world'
$test

Name 'Name'




