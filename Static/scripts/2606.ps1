Function Invoke-NamedParameters {
<#
.SYNOPSIS
    Invokes a method using named parameters.
.DESCRIPTION
    A function that simplifies calling methods with named parameters to make it easier to deal with long signatures and optional parameters.  This is particularly helpful for COM objects.
.PARAMETER Object
    The object that has the method.
.PARAMETER Method
    The name of the method.
.PARAMETER Parameter
    A hashtable with the names and values of parameters to use in the method call.
.PARAMETER Argument
    An array of arguments without names to use in the method call.
.NOTES
    Name: Invoke-NamedParameters
    Author: Jason Archer
    DateCreated: 2011-04-06

    1.0 - 2011-04-06 - Jason Archer
        Initial release.
.EXAMPLE
    $shell = New-Object -ComObject Shell.Application
    Invoke-NamedParameters $Shell "Explore" @{"vDir"="$pwd"}

    Description
    -----------    
    Invokes a method named "Explore" with the named parameter "vDir."
#>
    [CmdletBinding(DefaultParameterSetName = "Named")]
    param(
        [Parameter(ParameterSetName = "Named", Position = 0, Mandatory = $true)]
        [Parameter(ParameterSetName = "Positional", Position = 0, Mandatory = $true)]
        [ValidateNotNull()]
        [System.Object]$Object
        ,
        [Parameter(ParameterSetName = "Named", Position = 1, Mandatory = $true)]
        [Parameter(ParameterSetName = "Positional", Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Method
        ,
        [Parameter(ParameterSetName = "Named", Position = 2, Mandatory = $true)]
        [ValidateNotNull()]
        [Hashtable]$Parameter
        ,
        [Parameter(ParameterSetName = "Positional")]
        [Object[]]$Argument
    )

    end {  ## Just being explicit that this does not support pipelines
        if ($PSCmdlet.ParameterSetName -eq "Named") {
            ## Invoke method with parameter names
            ## Note: It is ok to use a hashtable here because the keys (parameter names) and values (args)
            ## will be output in the same order.  We don't need to worry about the order so long as
            ## all parameters have names
            $Object.GetType().InvokeMember($Method, [System.Reflection.BindingFlags]::InvokeMethod,
                $null,  ## Binder
                $Object,  ## Target
                ([Object[]]($Parameter.Values)),  ## Args
                $null,  ## Modifiers
                $null,  ## Culture
                ([String[]]($Parameter.Keys))  ## NamedParameters
            )
        } else {
            ## Invoke method without parameter names
            $Object.GetType().InvokeMember($Method, [System.Reflection.BindingFlags]::InvokeMethod,
                $null,  ## Binder
                $Object,  ## Target
                $Argument,  ## Args
                $null,  ## Modifiers
                $null,  ## Culture
                $null  ## NamedParameters
            )
        }
    }
}

<#
Examples

Calling a method with named parameters.

$shell = New-Object -ComObject Shell.Application
Invoke-NamedParameters $Shell "Explore" @{"vDir"="$pwd"}

The syntax for more than one would be @{"First"="foo";"Second"="bar"}

Calling a method that takes no parameters (you can also use -Argument with $null).

$shell = New-Object -ComObject Shell.Application
Invoke-NamedParameters $Shell "MinimizeAll" @{}
#>
