## Get-Screenshot -- THIS ONE works on PowerShell 1.0 and .Net 2.0 (or better) 
############################################################################################################
## Usage:
##    Get-Screenshot "C:\Screencaps\Screenshot.jpg"
##    Get-Screenshot "$pwd\Screen $(Get-Date -f 'yyyy-MM-dd HH.mm.ss').bmp"
##    Get-Screenshot "$pwd\$(Get-Date -f 'HH.mm.ss').png" | % { [Diagnostics.Process]::Start( $_ ) }
############################################################################################################
[Reflection.Assembly]::LoadWithPartialName( "System.Drawing" )
[Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms" )

function Get-Screenshot {
   param($filename)
   $bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen;

   $screenshot = new-object System.Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [System.Drawing.Graphics]::FromImage($screenshot)
   # $bounds.Location.Offset(50,50)
   $graphics.CopyFromScreen( $bounds.Location, [System.Drawing.Point]::Empty, $bounds.size)

   $screenshot.Save($filename)

   $graphics.Dispose()
   $screenshot.Dispose()
   
   ls $filename
}
