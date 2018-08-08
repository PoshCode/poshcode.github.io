function Restart-IISAppPool {
   [CmdletBinding(SupportsShouldProcess=$true)]
   #.Synopsis
   #  Restarts an IIS AppPool
   #.Parameter ComputerName
   #  The name of an IIS web server where the AppPool resides
   #.Parameter AppPool
   #  The name of the AppPool to recycle (if you include wildcards, results in an initial call to list all app pools)
   #.Parameter Credential
   #  Credentials to connect to the IIS Server
   #.Example
   #  Restart-IISAppPool "Classic .NET AppPool" -Cn WebServer1
   #
   #  Description
   #  -----------
   #  Restart the "Classic .NET AppPool" on WebServer1
   #.Example
   #  Restart-IISAppPool *Classic* -Confirm
   #
   #  Description
   #  -----------
   #  Restart all of the app pools with "Classic" in the name on the local IIS server, prompting for each one
   param(
      [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory= $true, Position=0)]
      [Alias("Name","Pool")]
      [String[]]$AppPool
   ,
      [Parameter(ValueFromPipelineByPropertyName=$true, Position=1)]
      [Alias("CN","Server","__Server")]
      [String]$ComputerName
   ,
      [Parameter()]
      [System.Management.Automation.Credential()]
      $Credential = [System.Management.Automation.PSCredential]::Empty
   )
   
   begin {
      if ($Credential -and ($Credential -ne [System.Management.Automation.PSCredential]::Empty)) {
         $Credential = $Credential.GetNetworkCredential()
      }
      Write-Debug ("BEGIN:`n{0}" -f ($PSBoundParameters | Out-String))

      $Skip = $false
      ## Need to test for AppPool existence (it's not defined in BEGIN if it's piped in)
      if($PSBoundParameters.ContainsKey("AppPool") -and $AppPool -match "\*") {
        $null = $PSBoundParameters.Remove("AppPool")
        $null = $PSBoundParameters.Remove("WhatIf")
        $null = $PSBoundParameters.Remove("Confirm")
        Write-Verbose "Searching for AppPools matching: $($AppPool -join ', ')"

        Get-WmiObject IISApplicationPool -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy @PSBoundParameters | 
        Where-Object { @(foreach($pool in $AppPool){ $_.Name -like $Pool -or $_.Name -like "W3SVC/APPPOOLS/$Pool" }) -contains $true } |
        Restart-IISAppPool
        $Skip = $true
      }
      $ProcessNone = $ProcessAll = $false;
   }
   process {
      Write-Debug ("PROCESS:`n{0}" -f ($PSBoundParameters | Out-String))
   
      if(!$Skip) {
        $null = $PSBoundParameters.Remove("AppPool")
        $null = $PSBoundParameters.Remove("WhatIf")
        $null = $PSBoundParameters.Remove("Confirm")
         foreach($pool in $AppPool) {
            Write-Verbose "Processing $Pool"
            if($PSCmdlet.ShouldProcess("Would restart the AppPool '$Pool' on the '$(if($ComputerName){$ComputerName}else{'local'})' server.", "Restart ${Pool}?", "Restarting IIS App Pools on $ComputerName")) {
               Write-Verbose "Restarting $Pool"
               # if($PSCmdlet.ShouldContinue("Do you want to restart $Pool?", "Restarting IIS App Pools on $ComputerName", [ref]$ProcessAll, [ref]$ProcessNone)) {
                 Invoke-WMIMethod Recycle -Path "IISApplicationPool.Name='$Pool'" -Namespace root\MicrosoftIISv2 -Authentication PacketPrivacy @PSBoundParameters
               # }
            }
         }
      }
   }
}
