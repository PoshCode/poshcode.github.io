function Get-Ignite2015Video {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$True,ValueFromPipeline=$true)]
    [string]$Session,
    [string]$Path = "C:\ignite\2015-videos"
  )

  begin {
    # Generate File URL. Had to make sure video names were upper case.
    # Lower case urls don't work.
    $fileUrl = "http://video.ch9.ms/sessions/ignite/2015/$($Session.ToUpper()).mp4"

    Write-Verbose -Message "URL: $fileUrl"
    
    # Test to see if location to save files exists, if not create it.
    if(!(Test-Path $path)) {
      New-Item $path -ItemType directory -Force
    }

    # Load the BitsTransfer module
    Import-Module -Name 'BitsTransfer'
  }

  process {
    # Download video files.
    Start-BitsTransfer -Source $fileUrl -Destination "$path\$Session.wmv" -Description "Downloading file $Session from Ignite 2015."
  }

  end {
    # Remove BitsTransfer Module
    Remove-Module -Name 'BitsTransfer'
  }
}
