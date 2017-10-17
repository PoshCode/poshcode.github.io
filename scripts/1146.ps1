function Get-WebServiceConnections()
{
  $results = @{}
  $perfmon = new-object System.Diagnostics.PerformanceCounter
  $perfmon.CategoryName = "Web Service"
  $perfmon.CounterName = "Current Connections"

  $cat = new-object System.Diagnostics.PerformanceCounterCategory("Web Service")
  $instances = $cat.GetInstanceNames()

  foreach ($instance in $instances)
  {
    $perfmon.InstanceName = $instance
    $results.Add($instance, $perfmon.NextValue())
  }
  write-output $results
}
