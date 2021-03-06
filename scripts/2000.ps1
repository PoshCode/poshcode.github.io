## NOTE: Destination must end in .bmp, .gif, .png, .wmp, .jpeg or .tiff
param($source = "C:\Windows\Web\Wallpaper\Windows\img0.jpg", $destination = "$Home\Pictures\thumb0.png", $scale = 0.25)
Add-Type -Assembly PresentationCore

## Open and resize the image
$image = New-Object System.Windows.Media.Imaging.TransformedBitmap (New-Object System.Windows.Media.Imaging.BitmapImage $source),
                                                                   (New-Object System.Windows.Media.ScaleTransform $scale,$scale)
## Put it on the clipboard (just for fun)
[System.Windows.Clipboard]::SetImage( $image )

## Write out an image file:
$stream = [System.IO.File]::Open($destination, "OpenOrCreate")
$encoder = New-Object System.Windows.Media.Imaging.$([IO.Path]::GetExtension($destination).substring(1))BitmapEncoder
$encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($image))
$encoder.Save($stream)
$stream.Dispose()
