$sevenz = 'D:\u\7-Zip\current\7z.exe'
$drops = 'D:\chromium\drops'

$VerbosePreference = 'Continue'

$wc = New-Object Net.WebClient
$url = 'http://build.chromium.org/buildbot/snapshots/chromium-rel-xp'

Write-Verbose 'Finding the latest build...'
$latest = [Int32]$wc.DownloadString("$url/LATEST")

if (-not $latest)
{
    throw 'Could not find the latest build.'
}

Write-Verbose "Latest build is $latest"

$source = "$url/$latest/chrome-win32.zip"
$dest = "$drops\chrome-win32-$latest"
$link = "$drops\latest"
$zip = "$dest.zip"

if (-not (Test-Path $dest))
{
    if (-not (Test-Path $zip))
    {
        Write-Verbose "Downloading the $latest win32 build..."
        $wc.DownloadFile($source, $zip)
    }

    Write-Verbose "Extracting $zip..."
    & $sevenz 'x' "-o$drops" -y $zip > $null

    if (($LASTEXITCODE) -or -not (Test-Path "$drops\chrome-win32"))
    {
        throw "Failed to extract $zip"
    }

    Rename-Item "$drops\chrome-win32" $dest -ea Stop
    Remove-Item $zip -Force -ea SilentlyContinue
}

Write-Verbose "Latest build exists in $dest"

if (Test-Path $link)
{
    cmd /c rd $link
}

cmd /c mklink /j $link $dest
