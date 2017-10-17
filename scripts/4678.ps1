$mailboxes = get-mailbox

$mailboxes| foreach-object {
	
	$alias = $_.alias
	$folders = get-mailboxfolderstatistics $_
	$foldernames = $folders|select-object name

	"--------------------------------------------------------------" | Out-File C:\MailboxPermissions.txt -append
	"" | Out-File C:\MailboxPermissions.txt -append
	 "Processing permissions on $alias" | Out-File C:\MailboxPermissions.txt -append
	 "" | Out-File C:\MailboxPermissions.txt -append
	$foldernames | foreach-object {

		$concat = $alias + ":\" + $_.name
		get-mailboxfolderpermission -identity $concat -erroraction silentlycontinue | ft foldername,User,AccessRights | Out-File C:\MailboxPermissions.txt -append
				      }
	 "" | Out-File C:\MailboxPermissions.txt -append
	 "--------------------------------------------------------------" | Out-File C:\MailboxPermissions.txt -append
			   }
