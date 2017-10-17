# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Chad Miller 
### </Author>
### <Description>
### Searches the registry key for the specified pattern on the specified computer
### Useful in finding installed S/W
### </Description>
### <Usage>
### ./RegQuery.ps1 Server1 "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" SQL
### </Usage>
### </Script>
# ---------------------------------------------------------------------------
param ($computer,$regkey,$pattern)

$p = $($regkey -replace "HKLM","HKEY_LOCAL_MACHINE") -replace "\\","\\"
$p += "(?<pattern>.*$pattern.*)"
$matchArray = @()

REG QUERY \\$computer\$regKey | foreach {  if ($_ -match $p) { $matchArray += $matches.pattern }}
if ($matchArray.length -gt 0)
{ $matchArray | foreach {new-object psobject |
            add-member -pass NoteProperty computer $computer |
            add-member -pass NoteProperty pattern $_}}
else {new-object psobject |
            add-member -pass NoteProperty computer $computer |
            add-member -pass NoteProperty pattern $null}
