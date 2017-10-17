function Get-Credential{ 
PARAM([String]$Title, [String]$Message, [String]$Domain, [String]$UserName, [switch]$Console)
   ## Carefully EA=SilentlyContinue and check for $True because by default it's MISSING (not False, as you might expect)
   $cp = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds ConsolePrompting -ea "SilentlyContinue").ConsolePrompting -eq $True

   if($Console -and !$cp) {
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" ConsolePrompting $True
   } elseif(!$Console -and $Console.IsPresent -and $cp) {
      Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" ConsolePrompting $False
   }

   ## Now call the Host.UI method ... if they don't have one, we'll die, yay.
   $Host.UI.PromptForCredential($Title,$Message,$UserName,$Domain)

   ## BoyScouts: Leave everything better than you found it (I'm tempted to leave it = True)
   Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" ConsolePrompting $cp
}
