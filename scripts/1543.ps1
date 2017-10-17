# References:
# http://blogs.msdn.com/powershell/archive/2009/12/05/new-object-psobject-property-hashtable.aspx
# http://poshoholic.com/2008/07/03/essential-powershell-name-your-custom-object-types/
# http://poshoholic.com/2008/07/05/essential-powershell-define-default-properties-for-custom-objects/

function New-PSOCustomObject {
    param(
          [Parameter(Mandatory=$true)]
          [string]$Name,
          [Parameter(Mandatory=$true)]
          [hashtable]$Properties,
          [Parameter()]
          [string[]]$DefaultProperties,
          [Parameter()]
          [hashtable]$ScriptMethods
         )
    
    $object = New-Object PSObject -Property $Properties
    
    $object.PSObject.TypeNames[0] = "System.Management.Automation.PSCustomObject.$($Name)"
    
    # Move Script Methods to Set-PSObjectDefaultProperties.
    # 
    if( $ScriptMethods ) {
        foreach( $key in $ScriptMethods.Keys ) {
            $object | Add-Member -MemberType ScriptMethod -Name $key -Value $ScriptMethods[$key]
        }
    }
    
    if( $DefaultProperties ) {
        Set-PSODefaultProperties -Object $object -DefaultProperties $DefaultProperties
    }
    
    return $object
}
