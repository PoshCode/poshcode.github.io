$spaces=0
for ([int]$rownum=1;;$rownum++) 
    {
    
    $StairDirection=[math]::floor($rownum/50)%2
    if ($StairDirection -eq 0)
        {
        for ($i=0; $i -lt $spaces; $i++) 
            {
            Write-Host " " -NoNewLine
            }
            $spaces++
        }
    if ($StairDirection -eq 1)
        {
            for ($j=0; $j -lt $spaces; $j++) 
                {
                Write-Host " " -NoNewLine
                }
           $spaces--
          if ($spaces -eq -1)
          {
          $spaces=1
          }
        }
        
    
    Write-Host " " -BackgroundColor "Green" 
}
