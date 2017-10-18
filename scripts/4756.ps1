function Get-PEManifest {
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
    try {
      -join ($SystemUtilsClass.GetType().InvokeMember('GetManifestFromPEResources',
                    [Reflection.BindingFlags]'Public, Static, InvokeMethod', $null,
                                     $SystemUtilsType, @($FileName)) | % {[Char]$_}
            )
    }
    catch {
      $_.Exception.Message
    }
  }
  end {}
}
