Function Get-FSMORoleOwner {
<#  
.SYNOPSIS  
    Retrieves the list of FSMO role owners of a forest and domain  
    
.DESCRIPTION  
    Retrieves the list of FSMO role owners of a forest and domain
    
.NOTES  
    Name: Get-FSMORoleOwner
    Author: Boe Prox
    DateCreated: 06/9/2011  

.EXAMPLE
    Get-FSMORoleOwner
    
    DomainNamingMaster  : dc1.rivendell.com
    Domain              : rivendell.com
    RIDOwner            : dc1.rivendell.com
    Forest              : rivendell.com
    InfrastructureOwner : dc1.rivendell.com
    SchemaMaster        : dc1.rivendell.com
    PDCOwner            : dc1.rivendell.com
    
    Description
    -----------
    Retrieves the FSMO role owners each domain in a forest. Also lists the domain and forest.  
          
#>
[cmdletbinding()]
Param ()
Try {
    $forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest() 
    ForEach ($domain in $forest.domains) {
        $forestproperties = @{
            Forest = $Forest.name
            Domain = $domain.name
            SchemaMaster = $forest.SchemaRoleOwner
            DomainNamingMaster = $forest.NamingRoleOwner
            RIDOwner = $Domain.RidRoleOwner
            PDCOwner = $Domain.PdcRoleOwner
            InfrastructureOwner = $Domain.InfrastructureRoleOwner
            }
        $newobject = New-Object PSObject -Property $forestproperties
        $newobject.PSTypeNames.Insert(0,"ForestRoles")
        $newobject
        }
    }
Catch {
    Write-Warning "$($Error)"
    }
}
