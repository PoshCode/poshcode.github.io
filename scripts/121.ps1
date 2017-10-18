# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Joel "Jaykul" Bennett
### </Author>
### <Description>
### Downloads a file from the web to the specified file path.
### </Description>
### <Usage>
### Get-URL http://huddledmasses.org/downloads/RunOnlyOne.exe RunOnlyOne.exe
### Get-URL http://huddledmasses.org/downloads/RunOnlyOne.exe C:\Users\Joel\Documents\WindowsPowershell\RunOnlyOne.exe
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param([string]$url, [string]$path)

if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) {
  $path = Join-Path $pwd (Split-Path -leaf $path)
}

"Downloading [$url]`nSaving at [$path]"
$client = new-object System.Net.WebClient
$client.DownloadFile( $url, $path )

$path

