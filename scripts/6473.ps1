@@# Working PowerGrowl Sample Goes Here
Clear-Host
$Location = $($Env:PSModulePath).Split(';')[0]

Import-Module $Location\PowerGrowl.psm1

Get-Module PowerGrowl | Format-List

#Register-GrowlType -AppName "PoshTwitter" -Name "Greetings" `
#    -Icon "C:\Users\username\Documents\WindowsPowerShell\Modules\default_icon.png"
#Send-Growl "Greetings" "Hello World!"


