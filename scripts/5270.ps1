#Windows PowerShell live session dump
PS D:\> $dll = (gcm -ea 0 -c Application compatui.dll).Definition
PS D:\> PS D:\> if ($dll -ne $null) {
>> Import-Module strings #I used my own module (analog of Sysinternals strings)
>> strings -n 7 $dll | ? {$_ -cmatch 'CompatUI|CLSID'}
>> }
>>
...
#this which I looked for
CompatUI.Util = s 'Util Class'
CLSID = s '{0355854A-7F23-47E2-B7C3-97EE8DD42CD8}'
...
PS D:\> $cu = [Activator]::CreateInstance(([Type]::GetTypeFromCLSID('{0355854A-7F23-47E2B7C3-97EE8DD42CD8}', $false)))
PS D:\> $cu -eq $null
False
PS D:\> $cu | gm


   TypeName: System.__ComObject#{c5a7c759-1e8d-4b1b-b1e4-59f7f9b5171b}

Name                   MemberType Definition
----                   ---------- ----------
CheckAdminPrivileges   Method     int CheckAdminPrivileges ()
GetExePathFromObject   Method     Variant GetExePathFromObject (string)
GetItemKeys            Method     Variant GetItemKeys (string)
IsCompatWizardDisabled Method     int IsCompatWizardDisabled ()
IsExecutableFile       Method     int IsExecutableFile (string)
IsSystemTarget         Method     int IsSystemTarget (string)
RemoveArgs             Method     Variant RemoveArgs (string)
RunApplication         Method     uint RunApplication (string, string, int)
SetItemKeys            Method     int SetItemKeys (string, Variant)


#great! I can check my rights!
PS D:\> [Boolean]$cu.CheckAdminPrivileges()
False
PS D:\> [Boolean]$cu.IsExecutableFile('D:\bin\sed.exe')
True
#attention! the fun!
PS D:\> Out-File src\dummy -Encoding ASCII -InputObject 'MZ'
PS D:\> [Boolean]$cu.IsExecutableFile('D:\src\dummy')
True
PS D:\> 
