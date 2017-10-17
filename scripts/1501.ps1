param([String] $inputPath, [String] $wildcard, [String] $outputPath = $inputPath

gci -path $inputPath\$wildcard | % {  
  $outputFile = Join-Path $outputPath ($_.Name.Replace($_.Extension, '.mp3'))  
  vlc -I dummy $_.FullName ":sout=#transcode{acodec=mp3,ab=128,channels=6}:standard{access=file,mux=asf,dst=$outputFile}" vlc://quit
  Get-Process vlc | % { $_.WaitForExit() }
}


