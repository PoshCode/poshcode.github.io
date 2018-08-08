#This script will map multiple pst files automatically
#If you work helpdesk like me, it will save you years on your life (not kidding)

#This bit of code is optional, its just to pretty up the shell
$host.ui.RawUI.WindowTitle = "PST Mapper"
$host.UI.RawUI.BackgroundColor = 'DarkBlue'
$host.UI.RawUI.ForegroundColor = 'White'
Clear-Host

[Reflection.Assembly]::LoadWithPartialname("Microsoft.Office.Interop.Outlook") | Out-Null
$outlook = New-Object -ComObject Outlook.Application

[string]$rootFolder = Read-Host "`nPath where your PST files are located"

#Do a recursive search of all subfolders for pst files
#Makes it possible for a user to just type "C:" if they aren't sure where their pst's are stored
$pstFiles = Get-ChildItem -Path $rootFolder -Filter *.pst -Recurse

if ($pstFiles) {
    $pstFiles | sort LastWriteTime -Descending | select LastWriteTime, Fullname | ft -auto 
} else {
    Write-Host "No pst files found" -ForegroundColor Red
    Start-Sleep -Seconds 5
    Break
}

#Users generally will keep older archived pst files they don't need to connect so this allows
#them to select files by date
[datetime]$cutoff = Read-Host "Only map files newer than (date)"

Write-Host "`nMapping pst files now.  This window will automatically close when the process is complete"

$pstFiles | where { $_.LastWriteTime -ge $cutoff } | ForEach-Object { $outlook.Session.AddStore($_.FullName) }



