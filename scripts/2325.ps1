#hashtable to object function.
#used to be able to make custom objects with math inside the pipeline 
#e.g. 1..10 | h20 { @{karl = $_;dude = $_+1} }
#gps | h20 { @{name = $_.processname; mem = $_.workingset / 1MB} }
function h20([scriptblock]$sb )
{
 begin {}
 process{ if ($sb -ne $null)
                {
                  $ht = &$sb;
                  if ($ht -is [hashtable])
                    {
                        New-Object PSObject -Property $ht}
                    }
                  if ($ht -is [object[]])
                    {
                    $ht | where { $_ -is [hashtable]} | % { New-Object PSObject -Property $_ }
                    }  
                }
            
 end{}
}
