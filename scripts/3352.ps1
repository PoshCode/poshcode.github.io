function findPermission ([string]$a, [string]$b)
{
$string = $a
$user = $b
$initialArray = @{}
$lowerArray = @{}
do{
$initialArray = get-acl $string | %{$_.access} | %{$_.IdentityReference}
$lowerArray = $initialArray | %{$_.value.toLower()} | %{$_.SubString(12)}
foreach($item in $lowerArray)
{
if($item.Contains($user))
{
$a1 = new-object -comobject wscript.shell
$b = $a1.popup($string,0,"Permission Found",1)
}
}
$string = $string.SubString(0, $string.LastIndexOf("\"))
}while($string.Contains("\"))
}

