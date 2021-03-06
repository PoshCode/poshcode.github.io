# NAME
#   Set-SendAs
#
# SYNOPSIS
#   Use the Set-SendAs cmdlet to grant or Remove SendAs permissions on a mailbox
#
# SYNTAX
#   Set-SendAs -Identity <MailboxIdParameter> -SendAs <MailboxIdParameter> -ou <OrganizationalUnit> [-Remove <SwitchParameter> [-Confirm [<SwitchParameter>]]] [-DomainController <Fqdn>]

Function EOSet-SendAs ($Identity, $SendAs, $ou, [Switch]$Remove, $DomainController = "dc01", [switch]$Confirm = $true)
{
	PROCESS
	{
		if(!$ou) {throw 'Required paramater $ou is missing.'}

		# Use pipeline input when parameter is not specified
		if($_)
		{
			if($_.Identity -and !$Identity) {$Identity = $_.Identity}
			if($_.SendAs -and !$SendAs) {$SendAs = $_.SendAs}
			if($_.ou -and !$ou) {$ou = $_.ou}
			if($_.remove -and !$remove) {$remove = $_.remove}
		}
		
		# Verify admin and user are both available
		$IdentityMbx = $Identity
		$SendAsMbx = $SendAs

		if([string]$Identity.GetType() -ne "Microsoft.Exchange.Data.Directory.Management.Mailbox" -and !($IdentityMbx = Get-Mailbox $Identity -DomainController $DomainController -OrganizationalUnit $ou -ErrorAction SilentlyContinue))
		{throw "The operation could not be performed becaues the object '$Identity' could not be found in the organization '$ou'"}

		if([string]$SendAs.GetType() -ne "Microsoft.Exchange.Data.Directory.Management.Mailbox" -and !($SendAsMbx = Get-Mailbox $SendAs -DomainController $DomainController -OrganizationalUnit $ou -ErrorAction SilentlyContinue))
		{throw "The operation could not be performed becaues the object '$SendAs' could not be found in the organization '$ou'"}

		# Make changes
		If(!$Remove) {$null = Add-ADPermission -Identity $IdentityMbx.DistinguishedName -User $SendAsMbx.DistinguishedName -ExtendedRights Send-As}
		Else {$null = Remove-ADPermission -Identity $IdentityMbx.DistinguishedName -User $SendAsMbx.DistinguishedName -ExtendedRights Send-As -Confirm:$Confirm}
	}
}
