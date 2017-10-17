#requires -version 2.0
gp -ea 0 HKLM:\SYSTEM\CurrentControlSet\Services\* | ? {
  $_.Type -eq 1 -and $_.ImagePath -ne $null
} | select @{
  N='Name';E={$_.PSChildName}
}, @{
  N='Path';E={
    $$ = $_.ImagePath.ToLower()
    if ($$.StartsWith(($pat = Split-Path -Leaf ($dir = [Environment]::SystemDirectory)))) {
      $script:itm = [Regex]::Replace($$, $pat, $dir)
    }
    elseif ($$.StartsWith('\') -and $$ -match $pat) {
      $$ = $$.Substring((($i = $$.IndexOf('\', 2)) + 1), ($$.Length - $i - 1))
      $script:itm = [Regex]::Replace($$, $pat, $dir)
    }
    $itm
  }
}, @{
  N='Description';E={
    $script:des = (gci $itm).VersionInfo
    $des.FileDescription
  }
}, @{
  N='Publisher';E={$des.CompanyName}
}, @{
  N='Version';E={$des.ProductVersion}
}, @{
  N='Error Control';E={'0x{0:X8}' -f $_.ErrorControl}
}, @{
  N='Launch Type';E={
    switch ($_.Start) {
      0 { 'Ring0' }    #low level driver
      1 { 'OnBoot' }   #load and init after kernel loading
      2 { 'Auto' }     #SCM loads driver automatically
      3 { 'Manual' }   #SCM loads driver when it need
      4 { 'Disabled' }
    }
  }
} | Out-GridView -Title Drivers
