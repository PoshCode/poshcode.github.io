Set-Alias gpek Get-ManagedPEKind

Set-Alias gpek Get-ManagedPEKind

function Get-ManagedPEKind {
  <#
    .EXAMPLE
        PS C:\>gpek dbg\app.exe
    .EXAMPLE
        PS C:\>gpek $([PSObject].Assembly.Location)
        You'll got MethodInvocationException!
  #>
  param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    $FileName = cvpa $FileName
    
    $pek = New-Object Reflection.PortableExecutableKinds
    $ifm = New-Object Reflection.ImageFileMachine
  }
  process {
    try {
      ([Reflection.Assembly]::ReflectionOnlyLoadFrom($FileName)
               ).ManifestModule.GetPEKind([ref]$pek, [ref]$ifm)
    }
    catch [BadImageFormatException] {
      Write-Host Can not reflect this. -fo Red
      break
    }
    catch [Management.Automation.MethodInvocationException] {
      Write-Host $_.Exception.Message -fo Yellow
      break
    }
    finally {
      $PEInfo = New-Object PSObject -Property @{
        Kind = $pek
        MachineType = $ifm
      }
    }
  }
  end {
    $PEInfo | fl
  }
}
