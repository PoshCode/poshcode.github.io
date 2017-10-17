# Replace-InTextFile.ps1
# Replace Strings in files
param ( 
        [string] $Path = "."
      , [string] $Filter           # Select no files, by default....
      , [string] $pattern = $(Read-Host "Please enter a pattern to match")
      , [string] $replace = $(Read-Host "Please enter a replacement string")
      , [switch] $recurse = $false
      , [switch] $caseSensitive = $false
)

if ($pattern -eq $null -or $pattern -eq "") { Write-Error "Please provide a search pattern!" ; return }
if ($replace -eq $null -or $replace -eq "") { Write-Error "Please provide a replacement string!" ; return }

function CReplace-String( [string]$pattern, [string]$replacement )
{
   process { $_ -creplace $pattern, $replacement }
}
function IReplace-String( [string]$pattern, [string]$replacement )
{
   process { $_ -ireplace $pattern, $replacement }
}

$files = Get-ChildItem -Path $Path -recurse:$recurse -filter:$Filter

foreach($file in $files) {
   Write-Host "Processing $($file.FullName)"
   if( $caseSensitive ) {
      $str = Get-Content $file.FullName | CReplace-String $pattern $replace
      Write-Host $str
      Set-Content $file.FullName $str
   } else {
      $str = Get-Content $file.FullName | IReplace-String $pattern $replace
      Write-Host $str
      Set-Content $file.FullName $str
   }
}

if($files.Length -le 0) { 
   Write-Warning "No matching files found"
}
