#Capture the PC Name
$PCNAME = Read-Host -Prompt "Which is the user's PC?"
#Test the Connection
$PING = (test-connection $PCNAME -count 1 -quiet)
    If ( $PING -eq $false)
        {
        Write-Host "Connection Failed"
        return
        }


# Stop wsearch
(Get-Service -Name wsearch -ComputerName $PCNAME).stop()
Write-Host "Windows search service has stopped"

# Delete Index database
start-sleep -seconds 5
C:\Windows\psexec -s \\$PCNAME cmd /c del "%ProgramData%\Microsoft\Search\Data\Applications\Windows\Windows.edb"

# Start wsearch

(Get-Service -Name wsearch -ComputerName $PCNAME).start()
Write-Host "Windows search service has started"

C:\Windows\PsExec.exe -s \\$PCNAME msg * /w "The windows indexing service has restarted, the database can take up to 7 days to rebuild."
Write-Host "The windows indexing service has restarted, the database can take up to 7 days to rebuild."
