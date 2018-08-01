function Get-MimeWithExtension {
  <#
    .EXAMPLE
        PS C:\>Get-MimeWithExtension 'E:\mus\Strangers in the night.mp3'
        E:\mus\Strangers in the night.mp3:audio/mpeg
        
        PS C:\>
  #>
  param(
    [Parameter(Mandatory=$true)]
    [String]$FileName
  )
  
  begin {
    $ext = ([IO.FileInfo](cvpa $FileName)).Extension.ToLower()
    $res = 'application/unknown'
  }
  process {
    try {
      $rk = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey($ext)
    }
    finally {
      if ($rk -ne $null) {
        if (($cur = $rk.GetValue('Content Type')) -ne $null) {
          $res = $cur
        }
        $rk.Close()
      }
    }
  }
  end {
    Write-Host $FileName`: -f Yellow -no
    $res
  }
}
