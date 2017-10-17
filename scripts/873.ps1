function whoami
{
     [System.Security.Principal.WindowsIdentity]::GetCurrent().Name		
}
