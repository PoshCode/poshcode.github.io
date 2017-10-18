function Get-Manipulator {
  <#
    .EXAMPLE
        PS C:\> Get-Manipulator Mouse
    .EXAMPLE
        PS C:\> Get-Manipulator Keyboard 0
    .NOTES
        Author: greg zakharov
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateSet("Keyboard", "Mouse")]
    [String]$ClassName,
    
    [Parameter(Position=1)]
    [ValidateRange(0, 1)]
    [Int16]$Point=1
  )
  
  begin {
    $dev = @{
      'Keyboard' = 'Kbdclass';
      'Mouse'    = 'Mouclass';
    }
    $key = 'HKLM:\SYSTEM\CurrentControlSet'
  }
  process {
    if (Test-Path ($sub = Join-Path $key ('Services\' + $dev[$ClassName] + '\Enum'))) {
      gp (Join-Path $key ('Enum\' + (gp $sub).([String]$Point))) | select Class, `
      ClassGUID, Service, DeviceDesc | fl
    }
  }
  end {}
}
