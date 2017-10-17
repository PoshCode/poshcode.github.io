#The PowerShell Talk
#Demo 2 - VM Easy Bake Oven
#XenServer

#Connect to XenServer
Get-Credential | connect-Xenserver -Url http://XenServer_URL/sdk

#Create the new VM
Create-XenServer:VM -NameLabel "Dave" -VCPUsAtStartup 1 -MemoryDynamicMax 536870912 -MemoryStaticMax 536870912 -MemoryDynamicMin 536870912 -MemoryStaticMin 536870912 -MemoryTarget 536870912

#Get some info on said VM
Get-XenServer:VM -name "Dave" | fl * | more

#Change the Memory
Get-XenServer:vm -name "Dave" | Set-XenServer:VM.MemoryDynamicMax -DynamicMax 268435456
Get-XenServer:vm -name "Dave" | Set-XenServer:VM.MemoryDynamicMin -DynamicMin 268435456
Get-XenServer:vm -name "Dave" | Set-XenServer:VM.MemoryStaticmin -StaticMin 268435456
Get-XenServer:vm -name "Dave" | Set-XenServer:VM.MemoryStaticMax -Value 268435456

#Delete the VM
Get-XenServer:vm -name "Dave" | Destroy-XenServer:VM
