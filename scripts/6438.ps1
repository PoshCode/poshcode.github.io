function divide-integer ([int]$dividend , [int]$divisor ){ [int]$local:remainder = $Null;return [Math]::DivRem($dividend,$divisor,[ref]$local:remainder);}
set-alias i/ divide-integer

i/ 10 3

function divide-integerpipe ([int]$divisor )
{ begin { [int]$local:remainder = $Null}
  process { [Math]::DivRem($_ ,$divisor,[ref]$local:remainder); }
}
@@set-alias i\ divide-integerpipe
10 | i\ 3

1..10 | i\ 3
