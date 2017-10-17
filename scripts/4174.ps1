<# 
.SYNOPSIS 
    Gets the Lync Version

.DESCRIPTION 
    Gets the Lync version of the local or remote computer

.PARAMETER ComputerName
    The Computer to Run this on.  Default is local host.

.EXAMPLE 
    PS> Get-LyncVersion

.EXAMPLE 
    PS> Get-LyncVersion -ComputerName LyncServer001

.NOTES 
    File Name: Get-LyncVersion.ps1
    Author:  Matthew Dreher - mattron<nospam>5000@yahoo.com
    Requires: Powershell V1

.LINK
    http://dreherfamily.org

#> 
#requires -Version 1.0 
param( 
[Parameter(position=0,Mandatory=$false)] 
[String]$ComputerName = "."
) 
Process 
{ 

    Get-WmiObject -query "SELECT Name,Version FROM win32_product WHERE Name like 'Microsoft Lync Server%'" `
        -ComputerName $ComputerName | ft Name, Version -AutoSize

}

