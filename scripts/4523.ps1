function Check-NewGmail {
  param(
    [String]$Email = (Read-Host "Enter your email"),    
    [Security.SecureString]$Password = (Read-Host "Enter email password" -as)
  )
  
  function str([Security.SecureString]$s) {
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    )
  }
  $com = New-Object -com MSXML2.XMLHTTP.3.0
  $com.open('GET', $('https://' + $Email + ':' + `
             (str $Password) + '@mail.google.com/mail/feed/atom'), $false)
  $com.setRequestHeader('Content-Type', 'application/x-www-from-urlcoded')
  $com.send()
  
  $com.responseText -match 'fullcount>\d+' | Out-Null; $res = ($matches[0] -split '>')[1]
  Write-Host You have $res new letter`(s`).
}
