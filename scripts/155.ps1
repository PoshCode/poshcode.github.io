#requires -version 2.0
## Get-PerformanceHistory.ps1
##############################################################################################################
## Lets you see the amount of time recent commands in your history have taken
## History:
## v2 - adds a ton of parsing to make the output pretty
##    - added measuring the scripts involved in the command, (uses Tokenizer)
##############################################################################################################
param( [int]$count=1, [int]$id=((Get-History -count 1| Select Id).Id) )

$Parser = [System.Management.Automation.PsParser]
function FormatTimeSpan($ts) {
   if($ts.Minutes) {
      if($ts.Hours) {
         if($ts.Days) {
            return "{0:##}d {1:00}:{2:00}:{3:00}.{4:00000}" -f $ts.Days, $ts.Hours, $ts.Minutes, $ts.Seconds, [int](100000 * ($ts.TotalSeconds - [Math]::Floor($ts.TotalSeconds)))
         }
         return "{0:##}:{1:00}:{2:00}.{3:00000}" -f $ts.Hours, $ts.Minutes, $ts.Seconds, [int](100000 * ($ts.TotalSeconds - [Math]::Floor($ts.TotalSeconds)))
      }
      return "{0:##}:{1:00}.{2:00000}" -f $ts.Minutes, $ts.Seconds, [int](100000 * ($ts.TotalSeconds - [Math]::Floor($ts.TotalSeconds)))
   }
   return "{0:#0}.{1:00000}" -f $ts.Seconds, [int](100000 * ($ts.TotalSeconds - [Math]::Floor($ts.TotalSeconds)))
}

Get-History -count $count -id $id | 
ForEach {
   $msr = $null
   $cmd = $_
   $len = 8
   $com = @( $Parser::Tokenize( $cmd.CommandLine, [ref]$null ) | 
                  where {$_.Type -eq "Command"} | 
                  foreach { get-command $_.Content } | 
                  where { $_.CommandType -eq "ExternalScript" } |
                  foreach { $_.Path } )

   # If we actually got a script, measure it out
   if($com.Count -gt 0){
      $msr = Get-Content -path $com | Measure-Object -L -W -C
   } else {
      $msr = Measure-Object -in $cmd.CommandLine -L -W -C
   }
   
   "" | Select @{n="Id";        e={$cmd.Id}},
               @{n="Duration";  e={FormatTimeSpan ($cmd.EndExecutionTime - $cmd.StartExecutionTime)}},
               @{n="Lines";     e={$msr.Lines}},
               @{n="Words";     e={$msr.Words}},
               @{n="Chars";     e={$msr.Characters}},
               @{n="Type";      e={if($com.Count -gt 0){"Script"}else{"Command"}}},
               @{n="Commmand";  e={$cmd.CommandLine}}
} | 
# I have to figure out what the longest time string is to make it look its best
Foreach { $len = [Math]::Max($len,$_.Duration.Length); $_ } | Sort Id |
Format-Table @{l="Duration";e={"{0,$len}" -f $_.Duration}},Lines,Words,Chars,Type,Commmand -auto


