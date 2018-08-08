function Get-ChildItemRecurse {
<#
.Synopsis
  Does a recursive search through a PSDrive up to n levels.
.Description
  Does a recursive directory search, allowing the user to specify the number of
  levels to search.
.Parameter path
  The starting path.
.Parameter fileglob
  (optional) the search string for matching files
.Parameter levels
  The numer of levels to recurse.
.Example
  # Get up to three levels of files
  PS> Get-ChildItemRecurse *.* -levels 3

.Notes
  NAME:      Get-ChildItemRecurse
  AUTHOR:    tojo2000
#Requires -Version 2.0
#>
  Param([Parameter(Mandatory = $true,
                   ValueFromPipeLine = $false,
                   Position = 0)]
        [string]$path = '.',
        [Parameter(Mandatory = $false,
                   Position = 1,
                   ValueFromPipeLine = $false)]
        [string]$fileglob = '*.*',
        [Parameter(Mandatory = $false,
                   Position = 2,
                   ValueFromPipeLine = $false)]
        [int]$levels = 0)

  if (-not (Test-Path $path)) {
    Write-Error "$path is an invalid path."
    return $false
  }

  $files = @(Get-ChildItem $path)

  foreach ($file in $files) {
    if ($file -like $fileglob) {
      Write-Output $file
    }

@@  #if ($file.GetType().FullName -eq 'System.IO.DirectoryInfo') {
    if ($file.PSIsContainer) {
      if ($levels -gt 0) {
          Get-ChildItemRecurse -path $file.FullName `
                               -fileglob $fileglob `
                               -levels ($levels - 1)
      }
    }
  }
}
