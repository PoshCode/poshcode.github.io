function Get-Path {
[CmdletBinding(DefaultParameterSetName="DriveQualified")]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias("PSPath")]
   [String]      
   $Path,
   [Parameter()]
   [Switch]$ResolvedPath,
   [Parameter(ParameterSetName="ProviderQualified")]
   [Switch]$ProviderQualified
   
)
   $Drive = $Provider = $null 
   $PSPath = $PSCmdlet.SessionState.Path
   
   if($ResolvedPath -and $ProviderQualified) {
      $ProviderPaths = $PSPath.GetResolvedProviderPathFromPSPath($Path, [ref]$Provider)
   } else {
      $ProviderPaths = @($PSPath.GetUnresolvedProviderPathFromPSPath($Path, [ref]$Provider, [ref]$Drive))
      if($ResolvedPath) {
         $ProviderPaths = $PSPath.GetResolvedProviderPathFromProviderPath($ProviderPaths[0], $Provider)
      }
   }
   
   foreach($p in $ProviderPaths) {
      if($ProviderQualified -or ($Drive -eq $null)) {
         if(!$PSPath.IsProviderQualified($p)) {
            $p = $Provider.Name + '::' + $p
         }
      } else {
         if($PSPath.IsProviderQualified($p)) {
            $p = $p -replace [regex]::Escape( ($Provider.Name + "::") )
         }
         $p = $p.Replace($Drive.Root, $Drive.Name + ":")
      } 
      $p
   }
}
