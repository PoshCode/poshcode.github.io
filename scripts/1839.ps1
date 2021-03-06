###########################################################################
#
# NAME: Spread-Mailboxes.ps1
#
# AUTHOR: Jan Egil Ring
# EMAIL: jer@powershell.no
#
# COMMENT: Script to spread mailboxes alphabetically across mailboxdatabases based on the first character in the user`s displayname.
#          For more information, see the following blog-post: http://blog.powershell.no/2010/05/14/script-to-spread-exchange-mailboxes-alphabetically-across-databases
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 14.05.2010 - Initial release
#
###########################################################################

#Add the Exchange Server 2010 Management Shell snapin
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue


#Loop through each mailbox
foreach ($mailbox in (Get-Mailbox -ResultSize unlimited)) {

$displayname = $mailbox.Displayname

#Determine which database the mailbox should reside on. Displaynames not matching [A-Z] on first character goes to the last database.
switch -regex ($displayname.substring(0,1)) 
    { 
       "[A-F]" {$mailboxdatabase = "MDB A-F"} 
       "[G-L]" {$mailboxdatabase = "MDB G-L"} 
       "[M-R]" {$mailboxdatabase = "MDB M-R"} 
       "[S-X]" {$mailboxdatabase = "MDB S-X" } 
       "[Y-Z]" {$mailboxdatabase = "MDB Y-Z" } 
        default {$mailboxdatabase = "MDB Y-Z" }
    }
 
#Move mailbox to the correct database if not already correct.
if (($mailbox.database.name) -ne $mailboxdatabase) {New-MoveRequest -Identity $mailbox -TargetDatabase $mailboxdatabase;Write-Host "Moving $displayname to $mailboxdatabase" -ForegroundColor Green}
 
}
