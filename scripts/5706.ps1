function Get-LastLogonTime {
  <#
    .NOTES
        Author: greg zakharov
  #>
  begin {
    $Marshal = [Runtime.InteropServices.Marshal]
    #SafeTokenHandle, SafeLocalAllocHandle and SafeLsaReturnBufferHandle
    'Token', 'LocalAlloc', 'LsaReturnBuffer' | % {
      $mscorlib = [Object].Assembly
      $bf = [Reflection.BindingFlags]36
    }{
      $type = "Safe$($_)Handle"
      Set-Variable "$($type)P" ($t = $mscorlib.GetType("Microsoft.Win32.SafeHandles.$type"))
      Set-Variable "$type" $t.GetConstructor($bf, $null, [Type[]]@([IntPtr]), $null)
    } #foreach
    
    [UInt32]$TokenStatistics = 10
    $STATUS_SUCCESS          = 0
    
    #OpenProcessToken, GetTokenInformation and LsaGetLoggonSessionData
    ($Win32Native = $mscorlib.GetType('Microsoft.Win32.Win32Native')).GetMethods(
      ($$ = [Reflection.BindingFlags]40)
    ) | ? {
      $_.Name -match '\A(OpenP|LsaG).*\Z'
    } | % {
      Set-Variable $_.Name $_
    }
    $GetTokenInformation = $Win32Native.GetMethod('GetTokenInformation', $$, $null, @(
      $SafeTokenHandleP, [UInt32], $SafeLocalAllocHandleP, [UInt32], [UInt32].MakeByRefType()
    ), $null)
    #SECURITY_LOGON_SESSION_DATA and TOKEN_STATISTICS
    $Win32Native.GetNestedTypes($bf) | ? {
      $_.Name -match '\A(SECURITY_L|TOKEN_ST).*\Z'
    } | % {
      Set-Variable $_.Name ([Activator]::CreateInstance($_))
    }
  }
  process {
    try {
      $SafeTokenHandle = $SafeTokenHandle.Invoke([IntPtr]::Zero)
      if (!$OpenProcessToken.Invoke($null, (
        $opt = [Object[]]@((Get-Process -Id $PID).Handle, [Security.Principal.TokenAccessLevels]8, $SafeTokenHandle)
      ))) {
        $Marshal::ThrowExceptionForHR($Marshal::GetHRForLastWin32Error())
      }
      
      [UInt32]$sz = $Marshal::SizeOf($TOKEN_STATISTICS)
      $ptr = $Marshal::AllocHGlobal($sz)
      $Marshal::StructureToPtr($TOKEN_STATISTICS, $ptr, $false)
      $SafeLocalAllocHandle = $SafeLocalAllocHandle.Invoke($ptr)
      
      if (!$GetTokenInformation.Invoke($null, (
        $gti = [Object[]]@($opt[2], $TokenStatistics, $SafeLocalAllocHandle, $sz, $sz)
      ))) {
        $Marshal::ThrowExceptionForHR($Marshal::GetHRForLastWin32Error())
      }
      
      $TOKEN_STATISTICS = $Marshal::PtrToStructure($gti[2].DangerousGetHandle(), $TOKEN_STATISTICS.GetType())
      $LUID = $TOKEN_STATISTICS.GetType().GetField('AuthenticationId', $bf).GetValue($TOKEN_STATISTICS)
      
      $SafeLsaReturnBufferHandle = $SafeLsaReturnBufferHandle.Invoke([IntPtr]::Zero)
      if ($LsaGetLogonSessionData.Invoke($null, (
        $lsa = [Object[]]@($LUID, $SafeLsaReturnBufferHandle)
      )) -ne $STATUS_SUCCESS) {
        $Marshal::ThrowExceptionForHR($Marshal::GetHRFormLastWin32Error())
      }
      
      $SECURITY_LOGON_SESSION_DATA = $Marshal::PtrToStructure(
        $lsa[1].DangerousGetHandle(), $SECURITY_LOGON_SESSION_DATA.GetType()
      )
      [DateTime]::FromFileTime(
        $SECURITY_LOGON_SESSION_DATA.GetType().GetField('LogonTime', $bf).GetValue($SECURITY_LOGON_SESSION_DATA)
      )
    }
    catch { $_ }
    finally {
      if ($lsa -is [Array] -and $lsa[1] -ne $null) { $lsa[1].Close() }
      if ($SafeLsaReturnBufferHandle -ne $null) { $SafeLsaReturnBufferHandle.Close() }
      if ($gti -is [Array] -and $gti[2] -ne $null) { $gti[2].Close() }
      if ($SafeLocalAllocHandle -ne $null) { $SafeLocalAllocHandle.Close() }
      if ($ptr -ne $null) { $Marshal::FreeHGlobal($ptr) }
      if ($opt -is [Array] -and $opt[2] -ne $null) { $opt[2].Close() }
      if ($SafeTokenHandle -ne $null) { $SafeTokenHandle.Close() }
    }
  }
  end {}
}
