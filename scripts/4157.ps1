#############################################################################################
#
# NAME: CreateLabs.ps1
# AUTHOR: Rob Sewell http://newsqldbawiththebeard.wordpress.com
# DATE:10/05/2013
#
# COMMENTS: This script will create 3 Windows Azure SQL Servers and open up RDP connections
# ready for use. There is also the scripts to remove the Windows Azure Objects to save on
# usage costs
# ------------------------------------------------------------------------


# Get the Windows Azures CmdLets then run this
Import-Module "c:\Program Files\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

# Get the Subscription File and Import it
Get-AzurePublishSettingsFile 

Import-AzurePublishSettingsFile FilepathtoPublishSettingsFile

<# Run this once to set up a Storage Account
New-AzureStorageAccount -StorageAccountName storageaccountname -location 'West Europe' -Label 'Storage Account for My Lab'
#>

Get-AzureSubscription #Note the name

#Set the storage account to the subscription
Set-AzureSubscription -SubscriptionName SubscriptionName -CurrentStorageAccount storageaccountname


#Some variables

# Use Get-AzureVMimage to find the one you want ie Get-AzureVMImage | where { ($_.ImageName -like "*SQL*") }|select ImageName 

$image = 'fb83b3509582419d99629ce476bcb5c8__Microsoft-SQL-Server-2012SP1-Standard-CY13SU04-SQL11-SP1-CU3-11.0.3350.0-B'
$SQL1 = 'SQL1'
$SQL2 = 'SQL2'
$SQL3 = 'SQL3'
$size = 'ExtraSmall'
$AdminUser = 'ChoosePCAdminName'
$password = 'SUPERCOMpl1c@teDPassword'
$Service = 'theservicenameyouchoose'
$Location = 'West Europe'

<# Run this the first time to create a Service

New-AzureService -ServiceName $Service  -Location $Location -Label 'SQLDBA with a Beard Service' 

#>

#Configure the VMs

$vm = New-AzureVMConfig -Name $SQL1 -InstanceSize $size -ImageName $image |
  Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows|
  Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57500 -LocalPort 1433 


$vm2 = New-AzureVMConfig -Name $SQL2 -InstanceSize $size -ImageName $image |
  Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows |
    Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57501 -LocalPort 1433


$vm3 = New-AzureVMConfig -Name $SQL3 -InstanceSize $size -ImageName $image |
  Add-AzureProvisioningConfig -AdminUsername $AdminUser -Password $password -Windows |
    Add-AzureEndpoint -Name "SQL" -Protocol "tcp" -PublicPort 57502 -LocalPort 1433| 
    Add-AzureEndpoint -Name PS-HTTPS -Protocol TCP -LocalPort 5986 -PublicPort 5986

#Provision the VMs

New-AzureVM -ServiceName $Service -VMs $vm, $vm2,$vm3 

# Get the RDP Files

$SQL1RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL1.rdp"
$SQL2RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL2.rdp"
$SQL3RDP = "$ENV:userprofile\Desktop\Azure\RDP\$SQL3.rdp"

Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL1 -LocalPath $SQL1RDP
Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL2 -LocalPath $SQL2RDP 
Get-AzureRemoteDesktopFile -ServiceName $Service -name $SQL3 -LocalPath $SQL3RDP

# Open the RDP Fies - Check the machine is up in your Management Portal

Invoke-Expression $SQL1RDP
Invoke-Expression $SQL2RDP
Invoke-Expression $SQL3RDP

# Now run the SetupVM script for each server

<# 

This is the clean up script to remove the servers and services

Run this first

 $SQL1Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL1}
 $SQL2Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL2}
 $SQL3Disk = Get-AzureDisk|where {$_.attachedto.rolename -eq $SQL3}

Then This

    Remove-AzureVM -Name $SQL1 -ServiceName $Service
    Remove-AzureVM -Name $SQL2 -ServiceName $Service
    Remove-AzureVM -Name $SQL3 -ServiceName $Service

Then wait a while and run this

 $SQL1Disk|Remove-AzureDisk -DeleteVHD
 $SQL2Disk|Remove-AzureDisk -DeleteVHD
 $SQL3Disk|Remove-AzureDisk -DeleteVHD

  #Remove-AzureService $Service

  Get-ChildItem "$ENV:userprofile\Desktop\Azure\RDP\*.rdp"|Remove-Item

  #>

  <# 

  This is the clean up script for variables

    
    Remove-Variable [a..z]* -Scope Global 
    Remove-Variable [1..9]* -Scope Global 

   #>
