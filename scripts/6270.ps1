######################################
# Install Dell OpenManage 32bit
# Configure racadm to the subnet
#
# Robert Bordeaux 11/25/2015
#
#
######################################

#configuration node
$node = 252
#subnet mask
$subnet = "255.255.255.0"
$mask = $subnet.ToString()
#installer and racadm paths
#$installer = "C:\Temp\OpenManage\windows\SystemsManagement\SysMgmt.msi"
$racadmexe = "C:\Program Files\Dell\SysMgt\idrac\racadm.exe"

#Get server Subnet and add $node
$ServerOctetOne = ipconfig | where-object {$_ –match “IPv4 Address”} | foreach-object{$_.Split(“:”)[1].Trim()} | foreach-object{$_.Split(“.")[-4]} 
$ServerOctetTwo = ipconfig | where-object {$_ –match “IPv4 Address”} | foreach-object{$_.Split(“:”)[1].Trim()} | foreach-object{$_.Split(“.")[-3]} 
$ServerOctetThree = ipconfig | where-object {$_ –match “IPv4 Address”} | foreach-object{$_.Split(“:”)[1].Trim()} | foreach-object{$_.Split(“.")[-2]} 
$ServerCFGNode = $ServerOctetOne + "." + $ServerOctetTwo + "." + $ServerOctetThree + "." + $node
$cfgnode = $ServerCFGNode.ToString()
#$ServerCFGNode.ToString() | Write-Host

#Get Server Gateway
$Gateway = ipconfig | where-object {$_ –match “Default Gateway”} | foreach-object{$_.Split(“:”)[1].Trim()}
$ServerGateway = $Gateway.ToString()
#$ServerGateway | Write-Host



#if (-not(Test-Path)) {}

#Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList /i,$installer,/qn -wait

& "C:\Program Files\Dell\SysMgt\idrac\racadm.exe" setniccfg -s $CFGNode $mask $ServerGateway
