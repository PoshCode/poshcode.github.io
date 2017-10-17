Set-Alias gmt Get-MachineType

function Get-MachineType {
  param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [String]$FileName
  )
  
  begin {
    $mo = 0x04; $po = 0x3c
    $raw = New-Object "Byte[]" 1024
    $FileName = cvpa $FileName
  }
  process {
    try {
      $fs = New-Object IO.FileStream($FileName, [IO.FileMode]::Open, [IO.FileAccess]::Read)
      [void]$fs.Read($raw, 0, 1024)
      [Int32]$res = [BitConverter]::ToUInt16($raw, ([BitConverter]::ToInt32($raw, $po) + $mo))
    }
    catch [Management.Automation.RuntimeException] {
      $exp = [Boolean]$_.Exception
    }
    finally {
      if ($fs -ne $null) {$fs.Close()}
    }
  }
  end {
    switch ($exp) {
      $true { Write-Host File is not valid PE.`n -fo Red}
      default { Write-Host MachineType: $([Reflection.ImageFileMachine]$res) `n -fo Magenta}
    }
  }
}
