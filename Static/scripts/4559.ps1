[Enum]::GetNames([Security.Principal.WellKnownSidType]) | % {
  $itm = [Security.Principal.WellKnownSidType]::$_
  try {
    $sid = New-Object Security.Principal.SecurityIdentifier($itm, $null)
    $sid.Translate([Security.Principal.NTAccount]).Value
  }
  catch {}
}
