# .NET 3.5 is required to use the System.IO.Pipes namespace
[reflection.Assembly]::LoadWithPartialName("system.core") | Out-Null
$pipeName = "pipename"
$pipeDir = [System.IO.Pipes.PipeDirection]::InOut
$pipe = New-Object system.IO.Pipes.NamedPipeServerStream( $pipeName, $pipeDir )
