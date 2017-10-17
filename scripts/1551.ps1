param([Parameter(Mandatory=$true)][string]$Path,[Parameter(Mandatory=$true)][string]$Destination)

Get-ChildItem -Path $Path | Where-Object { !$_.PSIsContainer } | foreach {
	$Target = Join-Path -Path $Destination -ChildPath (Split-Path -Leaf $_)
	if ( Test-Path -Path $Target -PathType Leaf ) {
		$PrevTargetBkup=([System.IO.Path]::ChangeExtension($Target, ".old"))
		if ( Test-Path -Path $PrevTargetBkup -PathType Leaf ) {
			Remove-Item -Force -Path $PrevTargetBkup
		}
		Rename-Item -Path $Target -NewName ([System.IO.Path]::ChangeExtension($Target, ".old"))
	}
	Copy-Item -Path $_ -Destination $Target
}
