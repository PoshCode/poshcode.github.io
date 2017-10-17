if (!(Test-Path alias:whatis)) { Set-Alias whatis Get-ObjectType }

function Get-ObjectType {
  <#
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$Object
  )
  
  $raw = gi (cvpa $Object)
  if ($raw.PSIsContainer) {
    "{0} - folder path`n" -f $raw
    return
  }
  
  if ([String]::IsNullOrEmpty($raw.Extension)) {
    "File has not an extension.`n"
    return
  }
  
  $raw = 'http://pc.net/extensions/file/' + $raw.Extension.Substring(1, $raw.Extension.Length - 1)
  &(cmd /c ftype (cmd /c assoc .htm).Split('=')[1]).Split('"')[1] $raw
}
