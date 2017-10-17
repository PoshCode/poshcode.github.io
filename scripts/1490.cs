$mappoint = New-WebServiceProxy http://staging.mappoint.net/standard-30/mappoint.wsdl -Namespace MapPoint
$FindService = new-object MapPoint.FindServiceSoap
# You need an account, sign up here: https://mappoint-css.live.com/mwssignup
$FindService.Credentials = Get-Credential 

function Find-ReverseGeoCode( [double]$Latitude, [double]$longitude, [switch]$force  ) 
{
   $Coords = new-object MapPoint.LatLong
   $Coords.Latitude = $Latitude
   $Coords.Longitude = $longitude
   $Locations = $FindService.GetLocationInfo( $Coords, "MapPoint.NA", $null)

   if($force) {
      return $Locations
   } elseif($Locations[0].Address) {
      return $Locations[0].Address # .FormattedAddress + " - " + $Locations[0].Address.CountryRegion
   } else {
      return $Locations | ?{ $_.Entity.TypeName -eq "PopulatedPlace" } # | %{ $_.Entity.DisplayName }
   }
}

function Find-GeoCode( $address, $country = "US" ) 
{
   $spec = new-object MapPoint.FindAddressSpecification
   $spec.DataSourceName = "MapPoint.NA"
   $spec.InputAddress = $FindService.ParseAddress( $address,  $country )
   
   $Found = $FindService.FindAddress( $spec )
   if($Found.NumberFound) {
      $found.Results | Select -expand FoundLocation | Select -Expand LatLong
   }
   #  if($Found.NumberFound -gt 1) {
   #     $found.Results| Select -expand FoundLocation | Select -Expand Address
   #  }
}

## This is how non-geography geeks think of them:
Set-Alias Find-Address Find-ReverseGeoCode
Set-Alias Find-Coordinates Find-GeoCode
