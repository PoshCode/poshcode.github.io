Function Get-Weather {
<#  
.SYNOPSIS  
   Display weather data for a specific country and city.
.DESCRIPTION
   Display weather data for a specific country and city. There is a possibility for this to fail if the web service being used is unavailable.
.PARAMETER Country
    URL of the website to test access to.
.PARAMETER ListCities
    Use the currently authenticated user's credentials  
.PARAMETER City
    Used to connect via a proxy         
.NOTES  
    Name: Get-Weather
    Author: Boe Prox
    DateCreated: 15Feb2011 
.LINK http://www.webservicex.net/ws/default.aspx
.LINK http://boeprox.wordpress.com       
.EXAMPLE  
    Get-Weather -Country "United States" -ListCities
    
Description
------------
Returns all of the available cities that are available to retrieve weather information from.
.EXAMPLE  
    Get-Weather -Country "United States" -City "San Francisco"
    
Description
------------
Retrieves the current weather information for San Francisco

#> 
[cmdletbinding(
	DefaultParameterSetName = 'Weather',
	ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = '',
            ValueFromPipeline = $True)]
            [string]$Country,
        [Parameter(
            Position = 1,
            Mandatory = $False,
            ParameterSetName = 'listcities')]
            [switch]$ListCities,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
            [string]$City                       
                        
        )
Begin {
    $psBoundParameters.GetEnumerator() | % {  
        Write-Verbose "Parameter: $_" 
        }     
    Try {
        #Make connection to known good weather service
        Write-Verbose "Create web proxy connection to weather service"
        $weather = New-WebServiceProxy 'http://www.webservicex.net/globalweather.asmx?WSDL'
        }
    Catch {
        Write-Warning "$($Error[0])"
        Break
        }        
    }
Process {
    #Determine if we are only to list the cities for a given country or get the weather from a city
    Switch ($PSCmdlet.ParameterSetName) {
        ListCities {
            Try {
                #List all cities available to query for weather
                Write-Verbose "Listing cities in country: $($country)"
                (([xml]$weather.GetCitiesByCountry("$country")).newdataset).table | Sort City | Select City
                Break
                }
            Catch {
                Write-Warning "$($Error[0])"
                Break
                }
            }
        Weather {
            Try {
                #Get the weather for the city and country
                Write-Verbose "Getting weather for Country: $($country), City $($city)"
                ([xml]$weather.GetWeather("$city", "$country")).CurrentWeather
                }
            Catch {
                Write-Warning "$($Error[0])"
                }
            }
        }
    }
End {
    Write-Verbose "End function, performing clean-up"
    Remove-Variable city -Force
    Remove-Variable country -Force
    }   
}     
