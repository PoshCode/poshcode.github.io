Function Out-ClipboardText
{
    [CmdletBinding()]
    
    Param
    (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Object[]]
        $InputObject,
        
        [Int32]
        $Width = 140,
        
        [Switch]
        $NoTrimWhitespace
    )
    
    Begin
    {
        If ( $NoTrimWhiteSpace )
        {
            $Pipeline = { Out-String -Stream -Width $Width | ForEach-Object { $_ } }.GetNewClosure( ).GetSteppablePipeline( )
        }
        Else
        {
            $Pipeline = { Out-String -Stream -Width $Width | ForEach-Object { $_.TrimEnd( $Null ) } }.GetNewClosure( ).GetSteppablePipeline( )
        }
        $Pipeline.Begin( $True )
        
        [String[]]$Lines = @()
    }
    
    Process
    {
        ForEach ( $Object in $InputObject )
        {
            $Lines += $Pipeline.Process( $Object )
        }
    }
    
    End
    {
        [Void]$Pipeline.End( )
        $Text = $Lines -join "`r`n"
        [System.Windows.Forms.Clipboard]::SetText( $Text, 'UnicodeText' )
    }
}
