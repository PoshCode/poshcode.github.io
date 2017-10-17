<#
Author: mazakane
This short script converts Time settings and displays a "productivity" Report with a goal of 81%

Example:
get-productivity -Start 8:00 -End 17:00
#>

function get-Productivity{
  param(
     $start,
     $end
     )
$a = ([datetime]::Parse("$start"))
$b = ([datetime]::Parse("$end"))
$lb = "0:30" #(Half an hour Break for lunch)
$Wrk = ($b-$a)

if (($Wrk.TotalHours) -gt "6") { $worktime = (($b - $a) - $lb)		#this is special in my company, if you work less than 6 hours the lunch break isn´t going to be substracted.
Write-Host "`nTotal working hours without Lunch break: $worktime`n" 
                              }
else {$worktime = ($b - $a)
Write-Host "`nTotal working hours including Lunch break: $worktime`n" 
      }
$total = [int]$worktime.TotalMinutes 

# This formula gets the minimum hours at which count you are at least 81% productive.
 
$prod = (($total*81)/100)/60 
 
Write-warning "`nTo be 81% productive you need to work at least: $prod hours..."
}
