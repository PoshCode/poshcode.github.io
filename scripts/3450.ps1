#========================================================================
# Created on:   6/8/2012 9:45 AM
# Created by:   Clint Jones
# Organization: Virtually Genius!
# Filename:     Report-DecomVMs
#========================================================================

#Load PowerCLI
Add-PSSnapin VMware.VimAutomation.Core

#Connect to vCenter
Connect-VIServer -Server <viserver> -Credential (Get-Credential)

#variables
$deletenow = @()
$deletesoon = @()

#Check to see what VMs are labeled DNR and have been powered off
$dnrvms = Get-VM | Where-Object {($_.Name.Contains("DNR")) -and ($_.PowerState -eq "PoweredOff")}

foreach ($dnrvm in $dnrvms)
{

    #Make sure that the VM has been powered off for more than 14 days
    [array]$poweroffs = Get-VM -Name $dnrvm.Name | Get-VIEvent -Start (Get-Date).AddDays(-14) | Where-Object {$_.FullFormattedMessage -like "*is powered off"}
    
    if ($poweroffs -eq $null)
    {
      #this vm has been off more than 14 days - take action
      $deletenow += $dnrvm.Name
    }
    else
    {
      #this vm has not been off more than 14 days - report but do not take action
      $deletesoon += $dnrvm.Name
    }
 
}

#Remove duplications
$deletesoon = $deletesoon | Select-Object -Unique
$deletenow = $deletenow | Select-Object -Unique
