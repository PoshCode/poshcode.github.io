## Start with a seed list of primes you know:
$global:primes = 2,3,5 #,7,11,13,17,19,23

## This function will get the "next" one, add it to the list, and return it
function Get-NextPrime { 
   $p = $primes[-1]
   while($p = $p+1){
   if(!$(foreach($i in $primes) { if($p%$i-eq0) { $i } })) {
      $global:primes += $p
      return $p
   }}
}
