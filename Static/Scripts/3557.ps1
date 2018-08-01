$DistGroup = XC2010Move
$MB2Move = Get-DistributionGroup XC2010Move | Get-DistributionGroupMember | Get-Mailbox | Where {($_.RecipientTypeDetails -eq "LegacyMailbox") -and ($_.MailboxMoveStatus -eq ‘None’)} | Get-Random -Count 20
$batch = "MoveMB_{0:ddMMM_yyyy}" -f (Get-Date)
ForEach ($SingleMailbox in $MB2Move) {New-MoveRequest –Identity $SingleMailbox -BadItemLimit 100 -AcceptLargeDataLoss -Batchname $batch}
$MB2RemoveFromDG = Get-DistributionGroup XC2010Move | Get-DistributionGroupMember | Get-Mailbox | Where {($_.RecipientTypeDetails -eq "UserMailbox") -and ($_.MailboxMoveStatus -eq ‘Completed’)}
ForEach ($member in $MB2RemoveFromDG){Remove-DistributionGroupMember -Identity XC2010Move -Member $member -Confirm:$False}
ForEach ($member in $MB2RemoveFromDG){Remove-MoveRequest -Identity $member -Confirm:$False}
