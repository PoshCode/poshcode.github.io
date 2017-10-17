#function Start-Elevated {
   param ($app) 
   $psi = new-object "System.Diagnostics.ProcessStartInfo"
   $psi.FileName = $app; 
   $psi.Arguments = [string]$args; 
   $psi.Verb = "runas";
   [System.Diagnostics.Process]::Start($psi)
#}
