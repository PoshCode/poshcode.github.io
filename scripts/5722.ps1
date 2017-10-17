(Get-Date) - [DateTime]::FromFileTime(
  [BitConverter]::ToInt64(
    (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Windows).ShutdownTime, 0
  )
) | Select-Object Days, Hours, Minutes, Seconds
