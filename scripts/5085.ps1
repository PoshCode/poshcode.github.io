function Send-Popup {

    param ($Computername,$Message)

    if (Test-Connection -ComputerName $Computername -Count 1 -Quiet){
        Invoke-Command -ComputerName $Computername -ScriptBlock { param ($m) msg * $m } -ArgumentList $Message
        Write-Host "Message sent!"
    } else {
        Write-Host "Computer not online"
    }

}
