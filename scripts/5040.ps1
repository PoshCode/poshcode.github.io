[CmdletBinding()]
PARAM(
	[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByValue=$true)]
	[string[]]$UserName
)

BEGIN
{
	foreach($user in $UserName)
	{
		Add-MailboxPermission -Identity $user -User $FullAccess -AccessRights Fullaccess
	}
}
