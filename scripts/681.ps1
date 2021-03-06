## Get-Credential 
## An improvement over the default cmdlet which has no options ...
###################################################################################################
## History
## v 1.2 Refactor ShellIds key out to a variable, and wrap lines a bit
## v 1.1 Add -Console switch and set registry values accordingly (ouch)
## v 1.0 Add Title, Message, Domain, and UserName options to the Get-Credential cmdlet
###################################################################################################
function Get-Credential{ 
PARAM([String]$Title, [String]$Message, [String]$Domain, [String]$UserName, [switch]$Console)
   $ShellIdKey = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"
   ## Carefully EA=SilentlyContinue because by default it's MISSING, not $False
   $cp = (Get-ItemProperty $ShellIdKey ConsolePrompting -ea "SilentlyContinue")
   ## Compare to $True, because by default it's $null ...
   $cp = $cp.ConsolePrompting -eq $True

   if($Console -and !$cp) {
      Set-ItemProperty $ShellIdKey ConsolePrompting $True
   } elseif(!$Console -and $Console.IsPresent -and $cp) {
      Set-ItemProperty $ShellIdKey ConsolePrompting $False
   }

   ## Now call the Host.UI method ... if they don't have one, we'll die, yay.
   $Host.UI.PromptForCredential($Title,$Message,$UserName,$Domain)

   ## BoyScouts: Leave everything better than you found it (I'm tempted to leave it = True)
   Set-ItemProperty $ShellIdKey ConsolePrompting $cp
}


