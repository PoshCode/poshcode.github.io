# original by c_shanklin @ http://communities.vmware.com/message/1013362#1013362
function New-VMHostShellAccount {
	param (
		$Name,
		$Password = $null, 
		$Description = $null, 
		$PosixId = $null
	)
	$SvcInstance = Get-View serviceinstance
	$AcctMgr = Get-View $SvcInstance.Content.AccountManager
	$AcctSpec = new-object VMware.Vim.HostPosixAccountSpec
	$AcctSpec.id = $Name
	$AcctSpec.password = $Password
	$AcctSpec.description = $Description
	$AcctSpec.shellAccess = $true # Enable shell access
	$AcctSpec.posixId = $PosixId
	$AcctMgr.CreateUser($AcctSpec) # Create user
	# Write new user to output stream just as New-VMHostAccount would
	Get-VMHostAccount | Where-Object { $_.Id -eq $Name }
}
