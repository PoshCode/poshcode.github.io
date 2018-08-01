# FoxPro does this:
# lcStringToRun =  "! \N C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe '\\NTSERVER\FinishImport.ps1 -CSV " + ALLTRIM(THISFORM.ordergenobj.ImportFileContents) + "'"
# So basically a powershell.exe call is being assembled and ran by FoxPro.


# My pimp FinishImport.ps1 does this:

[CmdletBinding()]
param(
	[string]$CSV
)
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Windows.Forms.MessageBox]::Show("Program ran.")
