function global:Enable-FusionLog {  
    Remove-ItemProperty HKLM:Software\Microsoft\Fusion -name EnableLog -ErrorAction SilentlyContinue  
    [void](New-ItemProperty  HKLM:Software\Microsoft\Fusion -name EnableLog -propertyType dword -ErrorAction Stop)  
    Set-ItemProperty  HKLM:Software\Microsoft\Fusion -name EnableLog -value 1 -ErrorAction Stop  
    Write-Host "Fusion log enabled.  Do not forget to disable it when you are done"  
}  
function global:Disable-FusionLog {  
    Remove-ItemProperty HKLM:Software\Microsoft\Fusion -name EnableLog -ErrorAction SilentlyContinue  
    Write-Host "Fusion log disabled"  
}  
