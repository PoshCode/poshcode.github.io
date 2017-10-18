function Demo-Pipeline {
   #.Synopsis
   #    Useful for demonstrating how pipeline output works
   #.Example
   #    1..3 | Demo-Pipeline Red | Demo-Pipeline Green -OutputFromBegin | Demo-Pipeline Blue
   [CmdletBinding()]
   param (
      [Parameter(Position=0)]
      [ConsoleColor]$Color,

      [Parameter(Position=1,Mandatory=$true,ValueFromPipeline=$true)]
      [String[]]$InputObject,

      [Switch]$OutputFromBegin,

      [Switch]$OutputFromEnd
   )
   begin {
      Write-Verbose "ENTER Begin $Color"
      if ($PSBoundParameters.ContainsKey("InputObject")) {
         Write-Warning "We don't process InputObject in begin, because that wouldn't be PowerShelly"
      }

      Write-Host "BEGIN ($Color)" -Foreground $Color

      $HasOutput = $false
      
      if($OutputFromBegin) {
         $HasOutput = $true
         Write-Output "$Color BEGIN OUTPUT"
      }


      Write-Verbose "EXIT Begin $Color"
   }
   process {
      Write-Verbose "ENTER Process $Color"
      # This happens for each item that comes through:
      Write-Host "PROCESS: $InputObject ($Color)" -Fore $Color

      # We add one output thing of our own..
      if(!$HasOutput -and !$OutputFromEnd) {
         $HasOutput = $true
         Write-Output "$Color PROCESS OUTPUT"
      }

      # We pass through the InputObject for the next guy
      Write-Output $InputObject

      Write-Verbose "EXIT Process $Color"
   }
   end {
      Write-Verbose "ENTER End $Color"

      # This happens just once, at the end (notice the last input object is still around):
      Write-Host "END: $InputObject ($Color)" -Fore $Color

      if($OutputFromEnd) {
         $HasOutput = $true
         Write-Output "$Color END OUTPUT"
      }

      Write-Verbose "EXIT End $Color"
   }
}
