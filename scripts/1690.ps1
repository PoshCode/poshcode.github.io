$rep_du_user = $env:userprofile
$repertoire_pst = ($rep_du_user+"\AppData\Local\Microsoft\Outlook")
$repertoire_sauvegarde = "directory"

#Kill de outlook
Get-Process | Where { $_.Name -Eq "outlook" } | Kill

#wait and see :)
sleep 10

#copy des pst
xcopy $repertoire_pst $repertoire_sauvegarde /D /E /C /R /H /I /K /Y /G

