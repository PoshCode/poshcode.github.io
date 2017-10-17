#Ty Lopes - Calgary - Oct 2012
#(Troy is a huge nerd)

#How to kill a process by username
#Originally created for a script (running under a sched task) that was not closing excel application after enumerating throught the excel file
#Powershell does not seem to close excel properly using the workbook.close function
#Note: could not kill the process when I included the extension... example notepad.exe has to be notepad for the $process variable

$username = "username"
$process= "notepad"

$owners = @{}
gwmi win32_process |% {$owners[$_.handle] = $_.getowner().user}
get-process $process | select processname,Id,@{l="Owner";e={$owners[$_.id.tostring()]}} | where-object {$_.owner -eq $username} | kill -force


