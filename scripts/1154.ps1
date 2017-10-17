function Convert-ToCHexString {
  param([String] $input)
  $ans = ''
  [System.Text.Encoding]::ASCII.GetBytes($str) | % { $ans += "0x{0:X2}, " -f $_ }
  return $ans.Trim(',',' ')
}
