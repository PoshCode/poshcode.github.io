function Get-Head {
#.Synopsis
#  Read the first few characters of a file, fast.
param(
#  The path to the file (no powershell parsing happens here)
[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
[Alias("Path","PSPath")]
[String]$FilePath, 
#  The number of characters you want to read
[Parameter(Mandatory=$false)]
[Int]$count=512, 
#  The encoding (UTF8 or ASCII)
[Parameter(Mandatory=$false)]
[ValidateSet("UTF8","ASCII")]
$encoding = "UTF8"
)
begin {
   if($encoding -eq "UTF8") {
      $decoder = New-Object System.Text.UTF8Encoding $true
   } else {
      $decoder = New-Object System.Text.AsciiEncoding
   }
   $buffer = New-Object Byte[] $count
}
process {
   $Stream = [System.IO.File]::Open($FilePath, 'Open', 'Read')
   $Null = $Stream.Read($buffer,0,$count)
   $decoder.GetString($buffer)
   $Stream.Close()
}
}

