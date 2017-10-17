@(gci (Split-Path $env:userprofile) | ? {
  $_.Name -ne 'All Users'
}) | % {
  '{0, 13}: {1}'-f $_.Name, (New-Object Security.Principal.NTAccount(
    (Join-Path ([Environment]::MachineName) $_.Name)
  )).Translate([Security.Principal.SecurityIdentifier])
}
''
