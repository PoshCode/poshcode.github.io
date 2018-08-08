#requires -version 2.0
function Add-Path {
  <#
    .SYNOPSIS
        Adds a directory to an environment path variable.
    .EXAMPLE
        PS C:\proj>Add-Path
        Adds current location to the system path.
    .EXAMPLE
        PS C:\proj>Add-Path -r
        Restores previous state of %PATH% variable.
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Position=0)]
    [ValidateScript({Test-Path $_})]
    [String]$Path = [IO.Directory]::GetCurrentDirectory(),
    
    [Parameter(Position=1)]
    [Switch]$Restore
  )
  
  begin {
    if (!(gi $Path).PSIsContainer) { Write-Error "Should be a directory." -ea 1 }
    $Path = (cvpa $Path).TrimEnd('\')
    if ($backup_path -eq $null) {
      $global:backup_path = $env:path
    }
  }
  process {
    switch ($Restore) {
      $true {
        $env:path = $backup_path
        rv backup_path -s Global -for -ea 0
      }
      default {
        if ($env:path.ToUpper().Split(';') -contains $Path.ToUpper()) { return }
        else { $env:path += ";$Path" }
      }
    } #switch
  }
  end {}
}
