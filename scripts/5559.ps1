function dostuffToAccounts{
param(
	$theseaccounts
)
	foreach($thisaccount in $theseaccounts){
	Do-thing $thisaccount -stuff
	}
}


$accounts = get-adaccounts *
