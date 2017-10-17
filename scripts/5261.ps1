﻿Get-WindowsFeature | where {$_.Installed -eq "Installed"} | where {$_.bestPracticesModelId -like "micro*"} | foreach { $_.BestPracticesModelId } | get-bpamodel | invoke-bpamodel
Get-WindowsFeature | where {$_.Installed -eq "Installed"} | where {$_.bestPracticesModelId -like "micro*"} | foreach { $_.BestPracticesModelId } | get-bpamodel | get-bparesult | Where { $_.Severity -ne "Information" } | out-file c:\BPA-All.txt -encoding ascii
