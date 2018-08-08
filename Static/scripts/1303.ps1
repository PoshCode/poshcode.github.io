function Get-UserProfile($accountName)
{
	[reflection.assembly]::LoadWithPartialName("Microsoft.SharePoint") | out-null
	[reflection.assembly]::LoadWithPartialName("Microsoft.Office.Server") | out-null
	
	$upm =[Microsoft.Office.Server.UserProfiles.UserProfileManager](
		[Microsoft.Office.Server.ServerContext]::Default)
		
	$upm.GetUserProfile($accountName)
}

function Get-UserProfileData($profile)
{
	$propsToDisplay = $upm.Properties | ? { $_.IsSystem -eq $false -and $_.IsSection -eq $false }
	
	$o = new-object PSObject
	$propsToDisplay | foreach {
		add-member -inp $o -membertype NoteProperty -name $_.Name -value $profile[$_.Name]
	}
	
	$o
}

@@#
@@#
@@#USAGE 1: (update one profile)
@@# $up = Get-UserProfile "spadmin"
@@# $up["YourCustomField"].Value = "new value"
@@# $up.Commit()
@@#
@@#USAGE 2: (export profile data to CSV)
@@#
@@# $upm = [Microsoft.Office.Server.UserProfiles.UserProfileManager](
@@#      [Microsoft.Office.Server.ServerContext]::Default)
@@# $unrolledProfilesCollection = $upm | foreach { $_ }
@@# $unrolledProfilesCollection | foreach { Get-UserProfileData $_ } | export-csv -NoTypeInformation "C:\temp\profiles.txt"
@@
@@

