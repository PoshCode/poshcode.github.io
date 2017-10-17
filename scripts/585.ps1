## Export-Screenshot to take a screenshot and save it to disk
#####################################################################################
## Usage:
##   Export-Screenshot sshot.png
##   Export-Screenshot screen.jpg (New-Object Drawing.Rectangle 0, 0, 640, 480)
#####################################################################################


$null = [Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms" )

# Get a screenshot as a bitmap      
function Get-Screenshot ([Drawing.Rectangle]$bounds) {
   $screenshot = new-object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($screenshot)
   # $bounds.Location.Offset(50,50)
   $graphics.CopyFromScreen( $bounds.Location, [Drawing.Point]::Empty, $bounds.size)
	$graphics.Dispose()
   return $screenshot
}

# Save a screenshot to file
function Export-Screenshot {
PARAM (
   [string]$FilePath, 
   [Drawing.Rectangle]$bounds = [Windows.Forms.SystemInformation]::VirtualScreen
)
   write-host "FilePath: $($FilePath)" -fore green

   # Fix paths, in case they don't set [Environment]::CurrentDirectory
   if(!(split-path $FilePath).Length) { 
      $FilePath = join-path $pwd (split-path $FilePath -leaf)
      Write-Host "FilePath: $($FilePath)" -fore magenta
   }
   
   write-host "FilePath: $($FilePath)" -fore cyan

   $screenshot = Get-Screenshot $bounds
   $screenshot.Save( $($FilePath) )
   $screenshot.Dispose()
   gci $FilePath
}



