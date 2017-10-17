Add-Type -assembly "Microsoft.Office.Interop.Outlook"
$Outlook = New-Object -comobject Outlook.Application
$namespace = $Outlook.GetNameSpace("MAPI")
$f = $namespace.Folders(2).Folders(2).Folders(6)
for ($index = 2; $index -le $f.Items.Count; $index = $index + 1)
{
  $i = $f.Items($index)   
  $fwAction = $i.Actions(3)
  $fwMsg = $fwAction.Execute()
  $fwMsg.SendUsingAccount = $namespace.Accounts[1]
  $fwMsg.To = "receipts@helloreceipts.com"
  $fwMsg.Send()
  Start-Sleep -m 250
}

