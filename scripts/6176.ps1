﻿$choices = [System.Management.Automation.Host.ChoiceDescription[]](
(New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Choose me!"),
(New-Object System.Management.Automation.Host.ChoiceDescription "&No","Pick me!"))

$Answer = $host.ui.PromptForChoice('Caption',"Message",$choices,(1))

Write-Output $Answer

$fields = new-object "System.Collections.ObjectModel.Collection``1[[System.Management.Automation.Host.FieldDescription]]"

$f = New-Object 	 "String Field"
$f.HelpMessage  = "This is the help for the first field"
$f.DefaultValue = "Field1"
$f.Label = "&Any Text"

$fields.Add($f)

$f = New-Object System.Management.Automation.Host.FieldDescription "Secure String"
$f.SetparameterType( [System.Security.SecureString] )
$f.HelpMessage  = "You will get a password input with **** instead of characters"
$f.DefaultValue = "Password"
$f.Label = "&Password"

$fields.Add($f)

$f = New-Object System.Management.Automation.Host.FieldDescription "Numeric Value"
$f.SetparameterType( [int] )
$f.DefaultValue = "42"
$f.HelpMessage  = "You need to type a number, or it will re-prompt"
$f.Label = "&Number"

$fields.Add($f)

$results = $Host.UI.Prompt( "Caption", "Message", $fields )

Write-Output $results
