function ConvertFrom-Html {
   #.Synopsis
   #   Convert a table from an HTML document to a PSObject
   #.Example
   #   Get-ChildItem | Where { !$_.PSIsContainer } | ConvertTo-Html | ConvertFrom-Html -TypeName Deserialized.System.IO.FileInfo
   #
   #   Demonstrates round-triping files through HTML
   param(
      # The HTML content
      [Parameter(ValueFromPipeline=$true)]
      [string]$html,

      # A TypeName to inject to PSTypeNames 
      [string]$TypeName
   )
   begin { $content = "$html" }
   process { $content += "$html" }
   end {
      [xml]$table = $content -replace '(?s).*<table[^>]*>(.*)</table>.*','<table>$1</table>'

      $header = $table.table.tr[0]  
      $data = $table.table.tr[1..1e3]

      foreach($row in $data){ 
         $item = @{}
         if($header.th) {
            for($i=0; $i -lt $header.th.Count; $i++){
              $item.($header.th[$i].InnerText) = $row.td[$i]
            }
         } else {
            for($i=0; $i -lt $header.td.Count; $i++){
              $item.($header.td[$i].InnerText) = $row.td[$i]
            }
         }
         $object = New-Object PSCustomObject -Property $item 
         if($TypeName) {
            $Object.PSTypeNames.Insert(0,$TypeName)
         }
         Write-Output $Object
      }
   }
}
