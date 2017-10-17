if (!(Test-Path alias:gfe)) { Set-Alias tfe Get-FileEncoding }

function Get-FileEncoding {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    [Text.Encoding] | Get-Member -Static -MemberType Property | % {$enc = @{}}{
      if (($bytes = [Text.Encoding]::($_.Name).GetPreamble()) -ne $null) {
        $enc[$_.Name] = $bytes
      }
    }
  }
  process {
    try {
      $fs = [IO.File]::OpenRead($FileName)
      $buf = New-Object "Byte[]" $fs.Length
      [void]$fs.Read($buf, 0, $buf.Length)
      
      if (($enc = $enc.Keys | ? {
        foreach ($arr in ($buf[0..1], $buf[0..2], $buf[0..3])) {
          (Compare-Object $enc[$_] $arr -SyncWindow 0) -eq $null
        }
      }).Length -eq 2) { $enc = 'UTF32' }
      if ($enc -eq $null) { $enc = 'UTF7' }
    }
    catch {}
    finally {
      if ($fs -ne $null) { $fs.Close() }
    }
  }
  end { [Text.Encoding]::$enc }
}
