#If you use .NET Framework 4.5 then the best way to create zip file will be using
#ZipFile class which defined in System.IO.Compression.FileSystem.dll assembly.
#If you use .NET Framework 3.0 then it possible to create zip file with next way:
function Add-FileToZip {
  <#
    .EXAMPLE
        PS C:\>Add-FileToZip E:\bin\whois.exe test.zip
  #>
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]$FileToCompress,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String]$ZipOutput
  )
  
  begin {
    Add-Type -Assembly WindowsBase
    
    [UInt32]$buff = 4096
    $FileToCompress = [IO.Path]::GetFileName($FileToCompress)
    
    function Copy-Stream([IO.FileStream]$inp, [IO.Stream]$out) {
      begin {
        if ($inp.Length -lt $buff) {[UInt32]$len = $inp.Length}
        else {$len = $buff}

        $buf = New-Object "Byte[]" $len
        }
      process {
        while (($read = $inp.Read($buf, 0, $buf.Length)) -ne 0) {
          $out.Write($buf, 0, $read)
        }
      }
    }
  }
  process {
    try {
      $zip = [IO.Packaging.Package]::Open($ZipOutput, [IO.FileMode]::OpenOrCreate)
      $uri = [IO.Packaging.PackUriHelper]::CreatePartUri(
        (New-Object Uri($FileToCompress, [UriKind]::Relative))
      )
      
      if ($zip.PartExists($uri)) {$zip.DeletePart($uri)}
      
      $pak = $zip.CreatePart($uri, '', [IO.Packaging.CompressionOption]::Maximum)
      
      $fs = New-Object IO.FileStream($FileToCompress, [IO.FileMode]::Open, [IO.FileAccess]::Read)
      $des = $pak.GetStream()
      Copy-Stream $fs $des
    }
    finally {
      if ($des -ne $null) {$des.Close()}
      if ($fs -ne $null) {$fs.Close()}
      if ($zip -ne $null) {$zip.Close()}
    }
  }
  end {}
}
#Note: this is just an example.
#If you still use PowerShell v2 and .NET Framework 2 then you can create zip with COM.
function Add-FileToZip {
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]$Path,
    
    [Parameter(Position=1)]
    [ValidateScript({$_ -match ".zip$"})]
    [String]$ZipFile = $((Get-Date -u %d%m%Y_%H%M%S) + ".zip")
  )
  
  begin {
    $com = New-Object -com Shell.Application
  }
  process {
    if (-not (Test-Path $ZipFile) -and (Test-Path $Path)) {
      sc $ZipFile ("PK" + [Char]5 + [Char]6 + ("$([Char]0)" * 18))
      (gi $ZipFile).IsReadOnly = $false
      $ZipFile = (gi $ZipFile).FullName
      
      gci -ea 0 $Path | % {
        if ($_.FullName -ne $zip) {
          $com.NameSpace($ZipFile).CopyHere($_.FullName)
          sleep -m 500
        }
      }
    }
  }
  end {}
}
#Also you can use third party libraries and modules :LOL:
