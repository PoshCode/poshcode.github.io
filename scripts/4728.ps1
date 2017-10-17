(New-Object Diagnostics.PerformanceCounterCategory(".NET CLR Memory")).GetInstanceNames() | ? {
  $_ -ne "_Global_"
}
