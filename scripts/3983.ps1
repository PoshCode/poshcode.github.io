function Mount-UserDrives {
  <#
    .Synopsis
        Create additional user drives.
    .Description
        To remove drives created with this function use Remove-UserDrives.
    .Link
        New-PSDrive
        Remove-UserDrives
  #>
  [Enum]::GetNames([Environment+SpecialFolder]) | % {
    New-PSDrive -n $_ -ps FileSystem -r $([Environment]::GetFolderPath($_)) -s Global | Out-Null
  }
}

function Remove-UserDrives {
  <#
    .Synopsis
        Remove additional user drives.
    .Description
        Dismount drives which mounted with Mount-UserDrives.
    .Link
        Remove-PSDrive
        Mount-UserDrives
  #>
  [Enum]::GetNames([Environment+SpecialFolder]) | % {
    Remove-PSDrive -n $_ -ps FileSystem -s Global
  }
}
