<#
    .Synopsis
        Download Google Chromium if there is a later build.
    .Description
        Download Google Chromium if there is a later build.        
#>

Set-StrictMode -Version Latest
Import-Module bitstransfer

# comment out when not debugging
$VerbosePreference = "Continue"
#$VerbosePreference = "SilentlyContinue"

$versionFile = "$Env:temp\latestChromiumVersion.txt"
$installedChromiumVersion = 0

trap [Exception] { 
      write-host
      write-error $("TRAPPED: " + $_.Exception.GetType().FullName); 
      write-error $("TRAPPED: " + $_.Exception.Message); 
      [string]($installedChromiumVersion) > $versionFile
      exit; 
}


if (Test-Path $versionFile)
{ $installedChromiumVersion = [int32] (cat $versionFile) }

$latestChromiumBuildURL ="http://build.chromium.org/f/chromium/snapshots/chromium-rel-xp"
Start-BitsTransfer "$latestChromiumBuildURL/LATEST" $versionFile
$latestChromiumVersion = [int32] (cat $versionFile)

if ($installedChromiumVersion -eq $latestChromiumVersion)
{ 
    Write-Verbose "Exiting... Version $installedChromiumVersion is the latest."
    return
}

$installerAppName = "mini_installer"
$installer = "$Env:temp\$installerAppName.exe"
Write-Verbose "Initiating download of new version $latestChromiumVersion"
Start-BitsTransfer "$latestChromiumBuildURL/$latestChromiumVersion/mini_installer.exe" $installer
Write-Verbose "Installing new version of Chromium"
Invoke-Item $installer
$installerRunning = 1
while (!($installerRunning -eq $null))
{ 
    sleep 5
    $installerRunning = ( Get-Process | ? {$_.ProcessName -match "$installerAppName"} )
}

Write-Verbose "New Chromium Installed! Please restart the Chromium browser"
