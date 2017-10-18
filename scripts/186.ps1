param($Cmdlet) $CmdletInfo = Get-Command -CommandType Cmdlet -Name $Cmdlet
    if ( $? ) {
        if ($CmdletInfo.GetType().Name -eq "CmdletInfo" ) {
            $parsed = $CmdletInfo.Definition `
                -replace "\] \[", "]`n[" `
                -replace "> \[", ">`n[" `
                -replace "$Cmdlet " `
                -split "`n" `
                -replace "\[-" `
                -replace "\]$"
            $parsed = $parsed | Sort-Object -Unique
            switch -regex ($parsed) {
                "^\["    { Write-host -ForegroundColor Green $_ }
                "Confirm|Debug|Verbose|WhatIf" { Write-Host -ForegroundColor Blue $_ }
                Default { Write-Host $_ }
            }
        }
    }
