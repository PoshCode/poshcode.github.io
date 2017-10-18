$FriendlyFolderName = "MyFriendlyAppV"
$appvroot = $(Get-Itemproperty HKLM:\SOFTWARE\Microsoft\AppV\Client\Streaming).PackageInstallationRoot
$appvPSroot = $appvroot.Replace('%programdata%',$env:ProgramData)

Get-AppvClientPackage | ForEach-Object {
    $targetpath = $appvPSroot + '\' + $_.PackageID.ToString() + '\' + $_.VersionID.ToString()
	$Path = "C:\ProgramData\" + $FriendlyFolderName + "\" + $_.Name
	New-Junction -LiteralPath $Path -TargetPath $targetpath
}
