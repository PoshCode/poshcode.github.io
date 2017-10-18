Set-Alias Ver Get-PSVersion
function Get-PSVersion
{
[string]$Major = ($PSVersionTable).PSVersion.Major
[string]$Minor = ($PSVersionTable).PSVersion.Minor
[string]$Out = $Major + '.' + $Minor
Write-Output $Out
}
