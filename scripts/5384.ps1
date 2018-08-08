function Get-RamLength {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  $raw = (
    reg query "HKLM\HARDWARE\RESOURCEMAP\System Resources\Physical Memory"
  )[-1][-1..-8]
  for ($i = 1; $i -lt $raw.Length; $i++) {
    $ram += $raw[$i..($i - 1)]
    $i++
  }
  '{0}Gb' -f [Math]::Round([Convert]::ToUInt32(-join $ram, 16) / 1Gb)
}
