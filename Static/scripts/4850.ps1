function ConvertFrom-Html {
   #.Synopsis
   #   Convert a table from an HTML document to a PSObject
   #.Example
   #   Get-ChildItem | Where { !$_.PSIsContainer } | ConvertTo-Html | ConvertFrom-Html -TypeName Deserialized.System.IO.FileInfo
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

         $h = "th"
         if(!$header.th) {
            $h = "td"
         }
         for($i=0; $i -lt $header.($h).Count; $i++){
            if($header.($h)[$i] -is [string]) {
               $item.($header.($h)[$i]) = $row.td[$i]
            } else {
               $item.($header.($h)[$i].InnerText) = $row.td[$i]
            }
         }
         Write-Verbose ($item | Out-String)
         $object = New-Object PSCustomObject -Property $item 
         if($TypeName) {
            $Object.PSTypeNames.Insert(0,$TypeName)
         }
         Write-Output $Object
      }
   }
}
