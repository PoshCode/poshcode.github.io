#function Join-Object {
   Param(
      [Parameter(Position=0)]
      $First
   ,
      [Parameter(Position=1)]
      $Second
   ,
      [Parameter(ValueFromPipeline=$true)]
      $InputObject
   )
   BEGIN {
      if($First -isnot [ScriptBlock]) {
         $Out1 = $First
         [string[]] $p1 = $First | gm -type Properties | select -expand Name
      }
   }
   Process {
      if($First -is [ScriptBlock]){
         $Out1 = $InputObject | &$First
         [string[]] $p1 = $Out1 | gm -type Properties | select -expand Name
      }
      
      $Output = $Out1 | Select $p1
      
      if($Second -is [ScriptBlock]) {
         $Out2 = $InputObject | &$Second
      } elseif(!$Second) {
         $Out2 = $InputObject
      } else {
         $Out2 = $Second
      }
      
      foreach($p in $Out2 | gm -type Properties | Where { $p1 -notcontains $_.Name } | select -expand Name) {
         Add-Member -in $Output -type NoteProperty -name $p -value $Out2.($p)
      }
      $Output
   }
#}
