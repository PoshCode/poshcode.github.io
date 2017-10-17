
$Raw = Whoami /groups
$Groups = $Raw | ?{ $_ -match "Enabled Group" } | %{$_.Split(" ,")[0] } | ?{ $_ -like "*\*" }| Sort 
$Groups

