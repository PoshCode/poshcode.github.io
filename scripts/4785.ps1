function Find-Executable {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    $FileName = cvpa $FileName
    
    $FindExecutable = ([PSObject].Assembly.GetType(
      'System.Management.Automation.NativeCommandProcessor'
    )).GetMethod('FindExecutable', [Reflection.BindingFlags]44)
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, 'Find executable for')) {
      $FindExecutable.Invoke($null, @($FileName))
    }
  }
  end {}
}
