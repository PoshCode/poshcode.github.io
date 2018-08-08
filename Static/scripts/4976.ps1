param (
    [string]$ConnectionString,
    [string]$DataSource,
    [string]$FileName,
    [int]$OleDbServices,
    [switch]$PersistSecurityInfo,
    [string]$Provider,
    [string]$ExtendedProperties
)

$builder = New-Object -TypeName System.Data.OleDb.OleDbConnectionStringBuilder

$PSBoundParameters.Keys | % { $key = $_ -creplace '([a-z])([A-Z])', '$1 $2'; $builder[$key] = $PSBoundParameters[$_].ToString() }

$builder.ConnectionString

