# author: jeffrey snover
# url: http://blogs.msdn.com/powershell/archive/2008/09/02/speeding-up-powershell-startup-updating-update-gac-ps1.aspx
Set-Alias ngen (Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
[AppDomain]::CurrentDomain.GetAssemblies() |
    sort {Split-path $_.location -leaf} | 
    %{
        $Name = (Split-Path $_.location -leaf)
        if ([System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($_))
        {
            Write-Host "Already GACed: $Name"
        }else
        {
            Write-Host -ForegroundColor Yellow "NGENing      : $Name"
            ngen $_.location | %{"`t$_"}
         }
      }
