param([type]$type = $(throw "need a type!"))

$type | Get-Member -static | Where {$_.membertype -eq "method" } | 
% {
   $func = "function:$($_.name)"
   if (test-path $func) { remove-item $func }
   new-item $func -value "[$($type.fullname)].InvokeMember('$($_.name)','Public,Static,InvokeMethod,DeclaredOnly', `$null, `$null, `$args[0])"
}
