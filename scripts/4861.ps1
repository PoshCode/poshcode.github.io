<#

.NOTES

    Author: Carsten Krüger - cakruege+poshcode@gmail.com

#>

Add-Type @'
public class MyAccounts
{
    public System.Collections.ArrayList users; 
    public System.Collections.ArrayList groups;
}
'@   

function get-localadministrators {
    param ([string]$computername=$env:computername)

    $computername = $computername.toupper()
    
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $computername)
                           
                $GroupPrincipal = New-Object System.DirectoryServices.AccountManagement.GroupPrincipal($PrincipalContext)
                $Searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher
                $Searcher.QueryFilter = $GroupPrincipal
                $localadmins = $Searcher.FindAll() | where {$_.Sid -eq 'S-1-5-32-544'} # Administrators group
                                              
                $users = New-Object System.Collections.ArrayList
                $groups = New-Object System.Collections.ArrayList
                
                $objOutput= New-Object MyAccounts
                              
                foreach ($ladmin in $localadmins.Members)
                {                 
                     if ($ladmin.ContextType -eq 'Machine')
                     {
                           [void] $users.Add($ladmin.Context.Name+'\'+$ladmin.SamAccountName)
                     }                                        
                    if ($ladmin.StructuralObjectClass -eq 'user') {
                      [void] $users.Add($ladmin.Context.Name+'\'+$ladmin.SamAccountName)
                    }                  
                    if ($ladmin.StructuralObjectClass -eq 'group') {
                      [void] $groups.Add($ladmin.Context.Name+'\'+$ladmin.SamAccountName)
                    }                                        
                }    
                
                $objOutput.users=$users
                $objOutput.groups=$groups
                
                    
    return $objoutput
}#end function
