[string]$rootDir = "C:\Build\"
[string]$buildDir = "C:\Build\build_dir\"
[string]$outputDir = "C:\Build\output_dir\"
[string]$svnDir = "C:\Build\build_dir\vacuum"
[string]$svnUrl = "http://vacuum-im.googlecode.com/svn/trunk/"

$currentScriptDirectory = Get-Location
[System.IO.Directory]::SetCurrentDirectory($currentScriptDirectory)
[Reflection.Assembly]::LoadFile(($currentScriptDirectory.Path + ".\SharpSvn-x64\SharpSvn.dll"))
$svnClient = New-Object SharpSvn.SvnClient
$repoUri = New-Object SharpSvn.SvnUriTarget($svnUrl)
Write-Host "Getting source code from subversion repository" $repoUri -ForegroundColor Green
$svnClient.CheckOut($repoUri, $svnDir)
$svnClient.GetInfo($SvnDir, ([ref]$svnInfo))
$rev = $svnInfo.Revision
Write-Host $rev

