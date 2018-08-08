Function Get-ClipboardText
{
    [CmdletBinding()]
    [OutputType([String])]
    
    Param() # No parameters
    
    [System.Windows.Forms.Clipboard]::GetText( 'UnicodeText' ) | Write-Output
}
