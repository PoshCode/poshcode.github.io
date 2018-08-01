function get-localadministrators {
    param ([string]$computername=$env:computername)

    $computername = $computername.toupper()
    
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                $PrincipalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine, $Computer)
                           
                $GroupPrincipal = New-Object System.DirectoryServices.AccountManagement.GroupPrincipal($PrincipalContext)
                $Searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher
                $Searcher.QueryFilter = $GroupPrincipal
                $objoutput = $Searcher.FindAll() | where {$_.Sid -eq 'S-1-5-32-544'} # Administrators group - http://support.microsoft.com/kb/243330
                
                #StructuralObjectClass=user
                #StructuralObjectClass=group
                #ContextType = Domain
                #ContextType = Machine
                    
    return $objoutput
}#end function
