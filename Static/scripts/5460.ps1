0..(($row = get-process | Format-Table * -AutoSize | Out-String -Stream).count - 1) | % {
    if ([bool]($_ % 2)) {
        Write-Host $row.item($_)
    } else {
        Write-Host $row.item($_) -ForegroundColor White -BackgroundColor DarkCyan        
    }
}
