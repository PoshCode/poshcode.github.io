$FolderPath = "\\FilerName\ShareName"


$rootfolder = Get-ChildItem -Path $FolderPath -recurse 
foreach ($file in $rootfolder) {
        $file.FullName
        Get-Acl $file.FullName | Format-List
            $acl = Get-Acl $file.FullName 
            $acl.Access | %{$acl.RemoveAccessRule($_)} 
            $acl.SetAccessRuleProtection($True, $False) 
            $Rights = [System.Security.AccessControl.FileSystemRights]::FullControl
            $inherit = [System.Security.AccessControl.FileSystemAccessRule]::ContainerInherit -bor [System.Security.AccessControl.FileSystemAccessRule]::ObjectInherit
            $Propagation = [System.Security.AccessControl.PropagationFlags]::None
            $Access = [System.Security.AccessControl.AccessControlType]::Allow
 #Copy the next 2 lines and uncomment them for each GROUP that you want to add      
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("DomainName\GroupName",$Rights, $inherit, $Propagation, $Access)
            $acl.AddAccessRule($rule)
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("DomainName\GroupName",$Rights, $inherit, $Propagation, $Access)
            $acl.AddAccessRule($rule)
 #Stays in Place to set the owner           
            $acct=New-Object System.Security.Principal.NTAccount("Builtin\Administrators") 
            $acl.SetOwner($acct) 
 #Applies all changes above to the ACL
            Set-Acl $file.FullName $acl 
            Get-Acl $file.FullName  | Format-List
            }
