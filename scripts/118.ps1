# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Joel "Jaykul" Bennett
### </Author>
### <Description>
### Selects a random element from the collection either passed as a parameter or input via the pipeline.
### If the collection is passed in as an argument, we simply pick a random number between 0 and count-1
### for each element you want to return, but when processing pipeline input we want to keep memory use 
### to a minimum, so we use a "reservoir sampling" algorithm[1].
###
### [1] http://gregable.com/2007/10/reservoir-sampling.html
###
### The script stores $count elements (the eventual result) at all times. It continues processing 
### elements until it reaches the end of the input. For each input element $n (the count of the inputs 
### so far) there is a $count/$n chance that it becomes part of the result.
### * For each previously selected element, there is a $count/($n-1) chance of it being selected 
### * For the ones selected, there's a ($count/$n * 1/$count = 1/$n) chance of it being replaced, so a 
###   ($n-1)/$n chance of it remaining ... thus, it's cumulative probability of being among the selected
###   elements after the nth input is processed is $count/($n-1) * ($n-1)/$n = $count/$n, as it should be.
###
### </Description>
### <Usage>
### $arr = 1..5; Select-Random $arr
### 1..10 | Select-Random -Count 2
### </Usage>
### <Version>2.2.0.0</Version>
### <History>
### <V id="2.0.0.0">Rewrote using the reservoir sampling technique</V>
### <V id="2.1.0.0">Fixed a bug in 2.0 which inverted the probability and resulted in the last n items being selected with VERY high probability</V>
### <V id="2.2.0.0">Use more efficient direct random sampling if the collection is passed as an argument</V>
### </History>
### </Script>
# ---------------------------------------------------------------------------
param([int]$count=1, [switch]$collectionMethod, [array]$inputObject=$null) 

BEGIN {
   if ($args -eq '-?') {
@"
Usage: Select-Random [[-Count] <int>] [-inputObject] <array> (from pipeline) [-?]

Parameters:
 -Count            : The number of elements to select.
 -inputObject      : The collection from which to select a random element.
 -collectionMethod : Collect the pipeline input instead of using reservoir
 -?                : Display this usage information and exit

Examples:
 PS> $arr = 1..5; Select-Random $arr
 PS> 1..10 | Select-Random -Count 2

"@
exit
   } 
   else
   {
      $rand = new-object Random
      if ($inputObject) 
      {
         # Write-Output $inputObject | &($MyInvocation.InvocationName) -Count $count
      }
      elseif($collectionMethod)
      {
         Write-Verbose "Collecting from the pipeline "
         [Collections.ArrayList]$inputObject = new-object Collections.ArrayList
      }
      else
      {
         $seen = 0
         $selected = new-object object[] $count
      }
   }
}
PROCESS {
   if($_)
   {
      if($collectionMethod)
      {
         $inputObject.Add($_) | out-null
      } else {
         $seen++
         if($seen -lt $count) {
            $selected[$seen-1] = $_
         } ## For each input element $n there is a $count/$n chance that it becomes part of the result.
         elseif($rand.NextDouble() -lt ($count/$seen))
         {
            ## For the ones previously selected, there's a 1/$n chance of it being replaced
            $selected[$rand.Next(0,$count)] = $_
         }
      }
   }
}
END {
   if (-not $inputObject)
   {  ## DO ONCE: (only on the re-invoke, not when using -inputObject)
      Write-Verbose "Selected $count of $seen elements."
      Write-Output $selected
      # foreach($el in $selected) { Write-Output $el }
   } 
   else 
   {
      Write-Verbose ("{0} elements, selecting {1}." -f $inputObject.Count, $Count)
      foreach($i in 1..$Count) {
         Write-Output $inputObject[$rand.Next(0,$inputObject.Count)]
      }   
   }
}
