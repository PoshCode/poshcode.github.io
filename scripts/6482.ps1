add-type -name Session -namespace "" -member @"
[DllImport("gdi32.dll")]
public static extern int AddFontResource(string filePath);
"@

foreach($font in Get-ChildItem -Recurse -Include *.ttf, *.otg) { [Session]::AddFontResource($font.FullName) }
