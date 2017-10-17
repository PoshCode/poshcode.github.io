function global:test-sccmagent {
param($PC)
[boolean]$result=get-wmiobject -Query "Select * from win32_service where Name = 'CcmExec'" -ComputerName $PC
return $result
}

