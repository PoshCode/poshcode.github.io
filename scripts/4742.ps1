function Get-MethodOpCodes {
  <#
    .EXAMPLE
        PS C:\>Get-MethodOpCodes ([AppDomain].GetMembers() | ? {$_.Name -eq 'CreateDomain'})[2]
        .method public hidebysig static system.appdomain CreateDomain (System.String friendlyName)
        {
                //Code size 9 (0x9)
                .maxstack 8

                IL_0000:         ldarg.0
                IL_0001:          ldnull
                IL_0002:          ldnull
                IL_0003:            call
                IL_0004:         stloc.1
                IL_0005:         ldarg.3
                IL_0006:             nop
                IL_0007:         ldloc.0
                IL_0008:             ret

        } //end of method [AppDomain]::CreateDomain
        PS C:\>
  #>
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [Reflection.MethodInfo]$MethodInfo
  )
  
  begin {
    [Reflection.Emit.OpCodes].GetMembers() | % {$opc = @{}}{
      if ($_.MemberType -ne 'Method') {
        $opc[$_.GetValue($null).Value] = $_.GetValue($null)
      }
    }

    $gmb = $MethodInfo.GetMethodBody()
    $ilb = $gmb.GetILAsByteArray()
    $par = ($MethodInfo.GetParameters() | % {'{0} {1}' -f $_.ParameterType.FullName, $_.Name}) -join ', '
    $arr = [RegEx]::Replace($MethodInfo.Attributes.ToString(), ', ', '$').Split('$')
  }
  process {
    $res = ".{0} {1} {2} {3} {4}" -f $MethodInfo.MemberType, $arr[1], $arr[3], $arr[2], $MethodInfo.ReturnParameter
    $res = "{0}{1} ({2})`n{{`n" -f $res.ToLower(), $MethodInfo.Name, $par
    $res += "`t//Code size {0} (0x{1:x})`n`t.maxstack {2}`n" -f $ilb.Length, $ilb.Length, $gmb.MaxStackSize
    $res += $(if ($gmb.LocalVariables -ne $null) {
      [RegEx]::Replace(("`t.locals init (" + ($gmb.LocalVariables | % {
        "[{0}] {1}," -f $_.LocalIndex, $_.LocalType.FullName
      }) + ")"), '\,\)', ')')
    })
    
    $res += $($ilb | % {$i = 0}{
      "`n`tIL_{0}: {1, 15}" -f $i.ToString("x4"), $opc[[Int16]$_].Name
      $i++
    }) + $("`n`n}} //end of method [{0}]::{1}" -f $MethodInfo.DeclaringType.Name, $MethodInfo.Name)
  }
  end {
    $res
  }
}
