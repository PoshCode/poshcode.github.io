# From "Unix like command for tac?" thread on posh NG
# solution by Keith Hill

param([string]$path)

$fs = New-Object System.IO.FileStream ((Resolve-Path $path), 'Open', 'Read')
trap { $fs.Close(); break }

$pos = $fs.Length
$sb = New-Object System.Text.StringBuilder
while (--$pos -ge 0) {
    [void]$fs.Seek($pos, 'Begin')
    $ch = [char]$fs.ReadByte()
    if ($ch -eq "`n" -and $sb.Length -gt 0) {
        $sb.ToString().TrimEnd()
        $sb.Length = 0
    }
    [void]$sb.Insert(0, [char]$ch)
}
$sb.ToString().TrimEnd()
