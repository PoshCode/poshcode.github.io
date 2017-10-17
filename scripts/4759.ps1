function Get-PEManifest {
  <#
    .EXAMPLE
        PS C:\>Get-PEManifets E:\SysInternals\whois.exe
    .NOTES
        Author: greg zakharov
  #>
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    Add-Type -Assembly System.Deployment
    
    $SystemUtilsType = ([AppDomain]::CurrentDomain.GetAssemblies() | ? {
      $_.Location.Split('\')[-1].Equals('System.Deployment.dll')
    }).GetType('System.Deployment.Application.Win32InterOp.SystemUtils')
    
    $SystemUtilsClass = [Activator]::CreateInstance($SystemUtilsType)
  }
  process {
    if ($PSCmdlet.ShouldProcess($FileName, 'Dumping manifest of')) {
      try {
        -join ($SystemUtilsClass.GetType().InvokeMember('GetManifestFromPEResources',
                      [Reflection.BindingFlags]'Public, Static, InvokeMethod', $null,
                                      $SystemUtilsType, @($FileName)) | % {[Char]$_})
      }
      catch {}
    }
  }
  end {}
}
