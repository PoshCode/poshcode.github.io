The final.csv file is the name of file which i created and its located on the desktop of the window server. after running the script i received this error
Import-Csv : Cannot open file "C:\Users\Administrator\final.csv".
At line:1 char:23
+ $Password = Import-Csv <<<<  final.csv| foreach { New-Mailbox -alias $_.Alias -name $_.Name
 -Database "mailbox database" -OrganizationalUnit Users -Password $Password -ResetPasswordOnNe
    + CategoryInfo          : OpenError: (:) [Import-Csv], FileNotFoundException
    + FullyQualifiedErrorId : FileOpenFailure,Microsoft.PowerShell.Commands.ImportCsvCommand
