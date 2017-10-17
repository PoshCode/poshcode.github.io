function Get-SignerName {
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    $FileName = cvpa $FileName
  }
  process {
    ([RegEx]'CN=([\w|\s])+').Match(
      (Get-AuthenticodeSignature $FileName).SignerCertificate.Subject
    ).Value.Split('=')[1]
  }
  end {}
}
