Function Create-DatePaths {
    Param (
        [Parameter(Position=0,Mandatory=$True)]
        [DateTime] $Start,
        [Parameter(Position=1,Mandatory=$True)]
        [ValidateScript({$_ -gt $Start})]
        [DateTime] $End,
        $DestinationPath=(Join-Path $env:UserProfile "Test")
    )

    0..(New-TimeSpan $Start $End).Days | % {
        $TargetPath = Join-Path $Destination $(Get-Date $Start -Format "yyyy\\MM-MMMM\\yyyy-MM-dd")
        If (!(Test-Path $TargetPath)) { New-Item $TargetPath -ItemType Directory }
        $Start = $Start.AddDays(1)
    }
}
