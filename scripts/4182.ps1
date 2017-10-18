<#
.SYNOPSIS
    Profile Property Privacy Proliferator
.NOTES
    Author: Josh Leach, Critigen
    Date:   23 May 2013
.DESCRIPTION
    Sets all UPSA users' privacy settings on a single property based on its default privacy setting. Before
    running this script, make sure you are an Administrator and a Full Control user on the target UPSA.
.PARAMETER Uri
    Base URI of a web application with a service connection to the UPSA with profiles you want to modify
.PARAMETER Property
    Name of the property to reset (object model names only, please)
.EXAMPLE
    .\p3.ps1 -Uri https://peopletest.int.ch2m.com -Property CellPhone
    Sets privacy to the UPSA's default value for [Mobile phone]
#>

# Here are some parameters!
Param(
  [parameter(Mandatory=$true)][string]
  [ValidateScript({
    Get-SPWeb $_
  })]$Uri,

  [parameter(Mandatory=$true)][string]
  $Property
)

#REGION Main Program

# Initialize progress bar and set up all the backend objects to query
Write-Progress -ID 1 -a "Starting..." -st "Prepping UPSA objects..." -pe 0
$site = Get-SPSite -Identity $Uri
$sctx = Get-SPServiceContext $site
$upsa = New-Object Microsoft.Office.Server.UserProfiles.UserProfileManager($sctx)
$upws = New-WebServiceProxy "$Uri/_vti_bin/userprofileservice.asmx" -UseDefaultCredential

# Determine the UPSA's default privacy setting
$propertyDefaultPrivacy = $upsa.Properties |? {$_.Name -eq $Property } | Select-Object -ExpandProperty DefaultPrivacy
if(!$propertyDefaultPrivacy) {
  Write-Error -Message "Could not find property with Name '$Property'" -Category InvalidArgument
  Exit
}
$propertyDefaultPrivacy = $propertyDefaultPrivacy.ToString()

# Get counters for the progress bar
$uc = 100/$upsa.Count; $cu = 0

# Begin looping through all users
$pe = $upsa.GetEnumerator()
foreach($userProfile in $pe) {
  Write-Progress -Id 1 -a "Processing users..." -st "Currently on $($userProfile['AccountName'])" -pe ($cu * $uc)

# Retrieve the original property value and its privacy settings
  $userProperty = $upws.GetUserPropertyByAccountName($userProfile['AccountName'],$Property)

# Modify property privacy value and flag that a change has been made (if it needs to be changed at all)
  if($userProperty.Privacy -ne $propertyDefaultPrivacy) {
    $userProperty.Privacy          = $propertyDefaultPrivacy
    $userProperty.IsPrivacyChanged = $true

# Modify the property
    $upws.ModifyUserPropertyByAccountName($userProfile['AccountName'],$userProperty)
  }

  $cu++  # Iterate counter variable
}

$site.Dispose()

#ENDREGION
