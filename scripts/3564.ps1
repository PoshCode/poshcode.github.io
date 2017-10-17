param(
#distribution group holding usermailbox(es)
[string] $DistGroup = "XC2010Move",
#move requests per batch/script run
[int] $BatchCount = 5
)

#remove user(s) without mailbox
Get-DistributionGroupMember $DistGroup  | get-user -Filter {Recipienttype -eq "User"} -EA SilentlyContinue | Remove-DistributionGroupMember -Identity $DistGroup -Confirm:$False
#remove mailbox(es) already moved to 2010 (by previous script run)
Get-DistributionGroupMember $DistGroup | Get-Mailbox -EA SilentlyContinue -RecipientTypeDetails "UserMailbox" | Remove-DistributionGroupMember -Identity $DistGroup -Confirm:$False
#get pre-2010 mailbox(es) not yet moved
$MB2Move = Get-DistributionGroupMember $DistGroup | Get-Mailbox -EA SilentlyContinue | Where {($_.RecipientTypeDetails -eq "LegacyMailbox") -and ($_.MailboxMoveStatus -eq ‘None’) -and ($_.ExchangeUserAccountControl -ne "AccountDisabled")} | Get-Random -Count $BatchCount
#create batch label as reference
$batch = "$($env:computername)_MoveMB_{0:ddMMM_yyyy}" -f (Get-Date)
#move pre-2010 mailbox(es)
ForEach ($SingleMailbox in $MB2Move) {New-MoveRequest –Identity $SingleMailbox -BadItemLimit 100 -AcceptLargeDataLoss -Batchname $batch}
#set quotas on moved mailbox(es)
Get-DistributionGroupMember $DistGroup | Get-Mailbox -RecipientTypeDetails "UserMailbox" -EA SilentlyContinue | Where {($_.MailboxMoveStatus -eq ‘Completed’)} | Set-Mailbox -Identity $_ -IssueWarningQuota "1920MB" -ProhibitSendQuota "1984MB" -ProhibitSendReceiveQuota "2048MB"}
#remove move request(s) upon completion
Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest -Confirm:$False

