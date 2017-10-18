function Save-CurrentFile ($path)
{
    $psISE.CurrentFile.SaveAs($path)
    $psISE.CurrentFile.Save([Text.Encoding]::default)

}

# Save-CurrentFile '.\Save-CurrentFile.ps1'


