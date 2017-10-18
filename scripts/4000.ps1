Function Update-WCContents($File,$SearchString,$NewValue){
    $Contents = Get-Content -Path $File
    $Contents | %{$_.Replace($SearchString,$NewValue)} | Set-Content $File    
} # End Update-WCContents Function
