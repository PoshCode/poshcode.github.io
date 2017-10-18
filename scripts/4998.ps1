$nextPlaylist = ((Get-Date).AddHours(1).ToString("MMddyyHH") + ".pla")

$files = Import-Csv -Header file,duration,flag C:\Users\Will\workspace\networx\06021400.pla #$nextPlaylist

Write-Host $nextPlaylist

Remove-Item C:\Users\Will\workspace\networx\current.pla

    foreach ($file in $files)
    {
        if ($file.file -ne {$_}) {
            $file.file + ".wav" | Out-File C:\Users\Will\workspace\networx\current.pla -Append
        }
    }
