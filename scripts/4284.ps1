function Close-Control
{
    param(
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [Windows.Media.Visual]
    $Visual
    )
    
    process {
        if ($Visual -is [Windows.Window]) {
            $Visual.Close()
        }
        if ($Visual.Parent -is [Windows.Window]) {
            $Visual.Close()
        }
        $Visual.Visibility = "Collapsed"
    }
} 

