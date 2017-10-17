# Pause-Script
#
# Pauses execution until a key is pressed.

function Pause-Script {
  param([string]$message = 'Press any key to continue...')
  Write-Host -NoNewLine $message
  $null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
  Write-Host ""
}


# Out-More
#
# Displays one window's worth of data at a time.
#
# Args:
#   $window_size: The number of lines to display
#
# Returns:
#   Each object in the input pipeline.

function Out-More {
  param ([int]$window_size = ($Host.UI.RawUI.WindowSize.Height - 1))
  $i = 0

  foreach ($line in $input) {
    Write-Output $line
    $i += 1

    if ($i -eq $window_size) {
      Pause-Script
      $i = 0
    }
  }
}



