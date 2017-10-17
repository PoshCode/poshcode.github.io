param (
    [string]$ConnectionString,
    [string]$Driver,
    [string]$Dsn
)

$builder = New-Object -TypeName System.Data.Odbc.OdbcConnectionStringBuilder

$PSBoundParameters.Keys | % { $key = $_ -creplace '([a-z])([A-Z])', '$1 $2'; $builder[$key] = $PSBoundParameters[$_].ToString() }

$builder.ConnectionString

