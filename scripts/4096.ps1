$Results = gci $env:userprofile\favorites -rec -inc *.url |
? {select-string -inp $_ -quiet "^URL=http"} |
select @{Name="Name"; Expression={[IO.Path]::GetFileNameWithoutExtension($_.FullName)}},
@{Name="URL"; Expression={get-content $_ | ? {$_ -match "^URL=http"} | % {$_.Substring(4)}}}

New-Item $env:userprofile\favorites\sorted -ItemType directory
foreach ($Result in $Results |Sort-Object -Property url)
{
    $Url = [System.Uri]$Result.URL
    if ($Url)
    {
        $Folders = $Url.Host.Split(".")
        if ($url.Host -eq 'agoodman.com.au')
        {
            #break
            }
        if ($Folders.Count -eq 2)
        {
            $RootFolder = $Folders[0]
            }
        if ($Folders.Count -eq 3)
        {
            $RootFolder = $Folders[1]
            if (($Folders[$Folders.Count-1]).Length -eq 2)
            {
                $RootFolder = $Folders[0]
                }
            }
        if ($Folders.Count -gt 3)
        {
            if (($Folders[$Folders.Count-1]).Length -eq 3)
            {
                $RootFolder = ($Folders[$Folders.Count-3])
                }
            }
        New-Item "$($env:userprofile)\favorites\sorted\$($RootFolder)" -ItemType Directory -Force

        $shell = New-Object -ComObject WScript.Shell
        $FileName = $Result.Name.Trim() -replace "[^a-zA-Z0-9\s]",""

        $path = "$($env:userprofile)\favorites\sorted\$($RootFolder)\$($FileName).URL"
        $ShortCut = $shell.CreateShortCut($path)
        $ShortCut.TargetPath = $Result.URL
        $ShortCut.Save()
    }
}
