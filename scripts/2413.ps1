# use it as follows:
# PS C:\> ps explorer | trim

add-type -Namespace Win32 -Name Psapi -MemberDefinition @"
[DllImport("psapi", SetLastError=true)]
public static extern bool EmptyWorkingSet(IntPtr hProcess);    
"@
 
filter Reset-WorkingSet {
    [Win32.Psapi]::EmptyWorkingSet($_.Handle)
}
 
sal trim Reset-WorkingSet

