# Unzip the file and keep the zip
# Unzip-File -FileName 'test.zip'
# Unzip the file and delete the zip
# Unzip-File -FileName 'test.zip' -DeleteSource $True
function Unzip-File {
	param (
		[parameter(mandatory=$true][ValidateNotNullOrEmpty()]$fileName,
		$DeleteSource = $false
	)
	$fileInfo = Get-Item -Path $FileName
	$appName = New-Object -ComObject Shell.Application
	$zipName = $appName.NameSpace($fileInfo.FullName)
	$extPath = $fileInfo.Directory.FullName + '\' + $fileInfo.BaseName
	$null = New-Item -Path $extPath -ItemType Directory -Force
	$dstFolder = $appName.NameSpace($extPath)
	$dstFolder.Copyhere($zipName.Items())
	If ($DeleteSource) {Remove-Item -Path $fileInfo.FullName}
}
function Unzip-MultipleFiles {
	param (
		[parameter(mandatory=$true)][ValidateNotNullOrEmpty()][string]$Path,
		$DeleteSource = $false
	)
	$Files = Get-ChildItem -Path $Path -Recurse -Include '*.zip' | Select FullName,Directory,BaseName
	$Files | % {
		Unzip-File -FileName $_.FullName
		If ($DeleteSource) {Remove-Item -Path $_.FullName}
	}
}
