[String]$buff = ""

while($true) {
  [Console]::ReadKey("`r") | % {
    if ($_.Key -eq 'Enter') {break}
    if ([Char]::IsLetterOrDigit($_.KeyChar) -or [Char]::IsWhiteSpace($_.KeyChar) -or`
        [Char]::IsPunctuation($_.KeyChar) -or [Char]::IsSymbol($_.KeyChar)) {
      $buff += $_.KeyChar
      Write-Host $_.KeyChar -no
    }
  }
}
""

if (-not [String]::IsNullOrEmpty($buff)) {
  Out-File ($pwd.Path + '\keylogger.log') -in $buff -enc ASCII -app -for
}
