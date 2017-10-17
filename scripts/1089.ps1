#The PowerShell Talk
#Demo 1 - Hypervisors
#Xen!

#Connect to XenServer
Get-Credential | connect-Xenserver -Url http://XenServer_URL/sdk

#Create Our Network
Create-XenServer:Network -NameLabel "Test Network"

#Change it's description
Get-XenServer:Network -NameFilter "Test Network" | Set-XenServer:Network.NameDescription "This is the test network for the XenServer Demo"

#Destroy it
Get-XenServer:Network -NameFilter "Test Network" | Destroy-XenServer:Network
