param(
#distribution group holding usermailbox(es)
[string] $DistGroup = "XC2010Move",
#move requests per batch/script run
[int] $BatchCount = 5
)

#remove user(s) without mailbox
Get-DistributionGroupMember $DistGroup  | get-user -Filter {Recipienttype -eq "User"} -EA SilentlyContinue | Remove-DistributionGroupMember -Identity $DistGroup -Confirm:$False
#set quotas on moved mailbox(es) and then remove from group
Get-DistributionGroupMember $DistGroup | Get-Mailbox -RecipientTypeDetails "UserMailbox" -EA SilentlyContinue | Where {($_.MailboxMoveStatus -eq ‘Completed’)} | Set-Mailbox -IssueWarningQuota "1920MB" -ProhibitSendQuota "1984MB" -ProhibitSendReceiveQuota "2048MB"
Get-DistributionGroupMember $DistGroup | Get-Mailbox -EA SilentlyContinue -RecipientTypeDetails "UserMailbox" | Remove-DistributionGroupMember -Identity $DistGroup -Confirm:$False
#remove move request(s) upon completion
Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest -Confirm:$False
#get pre-2010 mailbox(es) not yet moved
$MB2Move = Get-DistributionGroupMember $DistGroup | Get-Mailbox -EA SilentlyContinue | Where {($_.RecipientTypeDetails -eq "LegacyMailbox") -and ($_.MailboxMoveStatus -eq ‘None’) -and ($_.ExchangeUserAccountControl -ne "AccountDisabled")} | Get-Random -Count $BatchCount
#create batch label as reference
$batch = "$($env:computername)_MoveMB_{0:ddMMM_yyyy}" -f (Get-Date)
#move pre-2010 mailbox(es)
ForEach ($SingleMailbox in $MB2Move) {New-MoveRequest –Identity $SingleMailbox -BadItemLimit 100 -AcceptLargeDataLoss -Batchname $batch}

