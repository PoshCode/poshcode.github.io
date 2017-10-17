function Get-Type {
    <#
    .SYNOPSIS
        Get exported types in the current session

    .DESCRIPTION
        Get exported types in the current session

    .PARAMETER Module
        Filter on Module.  Accepts wildcard

    .PARAMETER Assembly
        Filter on Assembly.  Accepts wildcard

    .PARAMETER FullName
        Filter on FullName.  Accepts wildcard
    
    .PARAMETER Namespace
        Filter on Namespace.  Accepts wildcard
    
    .PARAMETER BaseType
        Filter on BaseType.  Accepts wildcard

    .PARAMETER IsEnum
        Filter on IsEnum.  Accepts wildcard

    .EXAMPLE
        #List the full name of all Enums in the current session
        Get-Type -IsEnum $true | Select -ExpandProperty FullName | Sort -Unique

    .EXAMPLE
        #Connect to a web service and list all the exported types
            
        #Connect to the web service, give it a namespace we can search on
            $weather = New-WebServiceProxy -uri "http://www.webservicex.net/globalweather.asmx?wsdl" -Namespace GlobalWeather

        #Search for the namespace
            Get-Type -NameSpace GlobalWeather
        
            IsPublic IsSerial Name                                     BaseType                                                                                                                                                                         
            -------- -------- ----                                     --------                                                                                                                                                                         
            True     False    MyClass1ex_net_globalweather_asmx_wsdl   System.Object                                                                                                                                                                    
            True     False    GlobalWeather                            System.Web.Services.Protocols.SoapHttpClientProtocol                                                                                                                             
            True     True     GetWeatherCompletedEventHandler          System.MulticastDelegate                                                                                                                                                         
            True     False    GetWeatherCompletedEventArgs             System.ComponentModel.AsyncCompletedEventArgs                                                                                                                                    
            True     True     GetCitiesByCountryCompletedEventHandler  System.MulticastDelegate                                                                                                                                                         
            True     False    GetCitiesByCountryCompletedEventArgs     System.ComponentModel.AsyncCompletedEventArgs   

    .FUNCTIONALITY
        Computers
    #>
    [cmdletbinding()]
    param(
        [string]$Module = '*',
        [string]$Assembly = '*',
        [string]$FullName = '*',
        [string]$Namespace = '*',
        [string]$BaseType = '*',
        [bool]$IsEnum
    )
    [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        Write-Verbose "Getting types from $($_.FullName)"
        Try
        {
            $_.GetExportedTypes()
        }
        Catch
        {
            Write-Verbose "$($_.FullName) error getting Exported Types: $_"
            $null
        }

    } | Where-Object { 
        $_.Module -like $Module -and
        $_.Assembly -like $Assembly -and
        $_.FullName -like $FullName -and
        $_.NameSpace -like $Namespace -and
        $_.BaseType -like $BaseType -and
        $(
            #This clause is only evoked if IsEnum is passed in
            if($PSBoundParameters.ContainsKey("IsEnum"))
            {
                $_.IsENum -like $IsEnum
            }
            else
            {
                $True
            }
        ) -and
        $_.IsPublic
    }
}

#Look for your dll...
get-type -Module "cassia.dll"

# Explore results as desired using Get-Member, Select-Object, maybe Show-Object
# http://www.powershellcookbook.com/recipe/bpqU/program-interactively-view-and-explore-objects
