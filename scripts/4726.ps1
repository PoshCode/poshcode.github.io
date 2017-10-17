#
# Opera 12 password recover sample
# Author: greg zakharov
# Inform me about bugs mailto:grishanz@yandex.ru
#
[Byte[]]$salt = 0x83, 0x7D, 0xFC, 0x0F, 0x8E, 0xB3, 0xE8, 0x69, 0x73, 0xAF, 0xFF
$path = [Environment]::GetFolderPath("ApplicationData") + "\Opera\Opera\wand.dat"

function Read-RawData([Byte[]]$key, [Byte[]]$enc) {
  $md5 = New-Object Security.Cryptography.MD5CryptoServiceProvider
  
  [Byte[]]$buff = New-Object "Byte[]" ($salt.Length + $key.Length)
  [Array]::Copy($salt, $buff, $salt.Length)
  [Array]::Copy($key, 0, $buff, $salt.Length, $key.Length)
  [Byte[]]$hash1 = $md5.ComputeHash($buff)
  
  [Byte[]]$buff = New-Object "Byte[]" ($hash1.Length + $salt.Length + $key.Length)
  [Array]::Copy($hash1, $buff, $hash1.Length)
  [Array]::Copy($salt, 0, $buff, $hash1.Length, $salt.Length)
  [Array]::Copy($key, 0, $buff, ($hash1.Length + $salt.Length), $key.Length)
  [Byte[]]$hash2 = $md5.ComputeHash($buff)
  
  $des = New-Object Security.Cryptography.TripleDESCryptoServiceProvider
  $des.Mode = [Security.Cryptography.CipherMode]::CBC
  $des.Padding = [Security.Cryptography.PaddingMode]::None
  
  [Byte[]]$trk = New-Object "Byte[]" 24
  [Byte[]]$IV  = New-Object "Byte[]" 8
  [Array]::Copy($hash1, $trk, $hash1.Length)
  [Array]::Copy($hash2, 0, $trk, $hash1.Length, 8)
  [Array]::Copy($hash2, 8, $IV, 0, 8)
  
  $des.Key = $trk
  $des.IV  = $IV
  [Security.Cryptography.ICryptoTransform]$dec = $des.CreateDecryptor()
  
  return [Text.Encoding]::Unicode.GetString($dec.TransformFinalBlock($enc, 0, $enc.Length))
}

try {
  [Byte[]]$wand = [IO.File]::ReadAllBytes($path)
  [Int32]$block = 0
  [String[]]$raw = ""
  $cat = [Enum]::GetValues([Globalization.UnicodeCategory])
  
  for ($i = 0; $i -lt $wand.Length; $i++) {
    if ($wand[$i] -eq 0x0 -and $wand[$i + 1] -eq 0x0 -and `
        $wand[$i + 2] -eq 0x0 -and $wand[$i + 3] -eq 0x8) {
      [Int32]$block = $wand[$i + 15]
      
      [Byte[]]$key = New-Object "Byte[]" 8
      [Byte[]]$enc = New-Object "Byte[]" $block
      [Array]::Copy($wand, ($i + 4), $key, 0, $key.Length)
      [Array]::Copy($wand, ($i + 16), $enc, 0, $enc.Length)
      
      $raw += (Read-RawData $key $enc)
      $i += 11 + $block
    }
  }
  
  if ($raw.Length -ne 0) {
    for ($i = 0; $i -lt $raw.Length; $i++) {
      if ($raw[$i] -match "@") {
        Write-Host $raw[$i].Split([Char]0x0)[0] -fo Green
        Write-Host $(-join ($raw[$i + 1].ToCharArray() | % {
          $chr = [Char]::GetUnicodeCategory($_)
          if ($chr -ne $cat[0] -and $chr -ne $cat[($cat.Length - 1)]) {
            $_
          }
        })) -fo Yellow
        ""
      }
    }
  }
}
catch [IO.FileNotFoundException] {
  $_.Exception.Message
}
