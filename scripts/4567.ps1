$ta = [Type]::GetType("System.Management.Automation.TypeAccelerators")
$ta::Get.Keys.GetEnumerator() | % {$arr = @()}{
  $arr += $($_ -ne 'accelerators')
}{
  if (-not ($arr -contains 'False')) {
    $ta::Add('accelerators', $ta)
  }
}
