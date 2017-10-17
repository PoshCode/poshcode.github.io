#hashtable to object function.
#used to be able to make custom objects with math inside the pipeline 
#examples 
#    1..10 | h20 { @{karl = $_;dude = $_+1} }
#modify the incoming data with an expression
#   gps | h20 { @{name = $_.processname; mem = $_.workingset / 1MB} }
#easily flatten data with subexpressions
#    get-command -verb get | h20 { @{ name = $_.name;  type = $_.commandtype; synopsis = ($_ | get-help).synopsis ;   } }
#don't lose the incoming pipeline data when you don't explicitly include it in the hashtable. Its automatically stored in the property ".."
#below, while the expression just includes string properties from the get-help object, the actual commandinfo object is stored in ".."
#  $a = get-command -verb ("get","set") | h20 { $_ | get-help | % { @{name = $_.name ; synopsis = $_.synopsis} } }
#  a[0].".."

function h20([scriptblock]$sb, [switch]$dontkeepreference = $false)
{
 begin {}
 process{ if ($sb -ne $null)
                {
                  $local:obj = $_;
                  $local:ht = &$sb;
                  if ($local:ht -is [hashtable])
                    {
                        if (!$dontkeepreference) { $local:ht.".." = $local:obj; }
                        New-Object PSObject -Property $local:ht 
                    }       
                 }
                  if ($local:ht -is [object[]])
                    {
                    $local:ht | where { $_ -is [hashtable]} | % { 
                            if (!$dontkeepreference) {$_.".." = $local:obj} 
                            New-Object PSObject -Property $_ }
                    }  
                }
            
 end{}
}
