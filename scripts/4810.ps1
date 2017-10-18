#Created by toussman@gmail.com on 17/01/2014 
#http://theplatformadmin.blogspot.co.uk/

param(
  [parameter(Mandatory = $True )][String]$GPOName
 )

$DCList = (get-addomaincontroller -filter *).hostname 

$colGPOVer = @()

foreach ($DC in $DCList){

 $objGPOVers = New-Object System.Object

 $GPOObj = Get-GPO $GPOName -server $DC

 $UserVersion = [string]$GPOObj.User.DSVersion + ' (AD), ' + [string]$GPOObj.User.SysvolVersion + ' (sysvol)'
 $ComputerVersion = [string]$GPOObj.Computer.DSVersion + ' (AD), ' + [string]$GPOObj.Computer.SysvolVersion + ' (sysvol)'

 $objGPOVers | Add-Member -type noteproperty -name GPOName -value $GPOName
 $objGPOVers | Add-Member -type noteproperty -name DCName -value $DC
 $objGPOVers | Add-Member -type noteproperty -name UserVersion -value $UserVersion
 $objGPOVers | Add-Member -type noteproperty -name ComputerVersion -value $ComputerVersion

 $colGPOVer += $objGPOVers 
}

$colGPOVer | sort-object GPOName, DCName
