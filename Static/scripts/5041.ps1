[CmdletBinding()]
PARAM(
	[Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
	[string[]]$UserName
)

PROCESS
{
	foreach($user in $UserName)
	{
		Add-MailboxPermission -Identity $user -User $FullAccess -AccessRights Fullaccess
	}
}
