function Where-Like {
	Param($member, $string)
	process { $input | where {$_.$member -like $string} } 
}
