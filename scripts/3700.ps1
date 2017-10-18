Function Get-SvnInfo {
[cmdletbinding()]

Param(
[ValidateScript({Test-Path $_})]
[string]$rootDir = "C:\Build\",
[ValidateScript({Test-Path $_})]
[string]$buildDir = "C:\Build\build_dir\",
[ValidateScript({Test-Path $_})]
[string]$outputDir = "C:\Build\output_dir\",
[ValidateScript({Test-Path $_})]
[string]$svnDir = "C:\Build\build_dir\vacuum",
[ValidateNotNullorEmpty()]
[string]$svnUrl = "http://vacuum-im.googlecode.com/svn/trunk/"
)

Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

Try {
    Write-Verbose "Loading SharpSvn assembly"
    $dll = Add-Type -AssemblyName "SharpSvn" -ErrorAction Stop
    <#
      I don't have this available so I can't completely test, 
      but if this file, SharpSvn-x64\SharpSvn.dll, is registered
      with the .Net framework, you should be able to load it by
      its name, which I think is SharpSvn.
    #>
}
Catch {
    $msg = "Failed to load required SharpSvn assembly. {0}" -f $_.Exception.message
    Write-Warning -Message $msg
}

If ($dll) {
    #Only run this code if the assembly was found and loaded
    Write-Verbose -Message "Creating SvnClient"
    $svnClient = New-Object SharpSvn.SvnClient

    Write-Verbose -Message "Creating SvnUriTarget $svnUrl"
    $repoUri = New-Object SharpSvn.SvnUriTarget($svnUrl)

    Write-Host "Getting source code from subversion repository $repoUri" -ForegroundColor Green

    Write-Verbose -Message "Checking out to $svnDir"
    $svnClient.CheckOut($repoUri, $svnDir)

    Write-Verbose -Message "Getting info"
    $svnClient.GetInfo($SvnDir, ([ref]$svnInfo))
    $rev = $svnInfo.Revision

    #write revision info to the pipeline
    Write-Output $rev
}

Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"

} #end function

