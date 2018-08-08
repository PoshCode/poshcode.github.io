$col = [Enum]::GetValues([ConsoleColor])

for ($i = 0; $i -lt $col.Length; $i++) {
  if ($col[$i] -ne $host.UI.RawUI.BackGroundColor) {
    Write-Host $col[$i] -fo $col[$i]
  }
}
