Select-String "(MSIE [0-9]\.[0-9]|Firefox\/[0-9]+|Safari|-)" $log -all |
Group  { $_.matches[-1].Value } | 
ForEach -begin   { $total = 0 } `
	-process { $total += $_.Count; $_ } | 
Sort Count | Select Count, Name |
Add-Member ScriptProperty Percent { "{0,7:0.000}%" -f (100*$this.Count/$Total) } -Passthru

#### Or if you prefer, the way I originally wrote it ###### 
##
## sls "(MSIE [0-9]\.[0-9]|Firefox\/[0-9]+|Safari|-)" $log -a |
## Group { $_.matches[-1].Value } | % {$t+=$_.Count; $_ } -b {$t=0} | 
## Sort Count | Select Count, Name |
## Add-Member ScriptProperty Percent { "{0,7:0.000}%" -f (100*$this.Count/$t) } -Pass

#### Sample output ###### 

Count Name                                    Percent
----- ----                                    -------
   34 Firefox/1                                 2.4% 
  139 MSIE 8.0                                  0.3% 
  290 -                                         1.2% 
  363 Firefox/2                                 3.0% 
  632 MSIE 6.0                                  5.3% 
 1708 Safari                                   14.3%
 3207 MSIE 7.0                                 27.0%
 5534 Firefox/3                                46.4%
