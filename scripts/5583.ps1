<#
Hi, my name is Kali Al Bin Jazis. I was looking for a way to create structures in PowerShell as it is done in C. I quite accidentally found the project on github named ""scope"". Author of this project has found a way to create structures very elegant way. For example:

struct IMAGE_DOS_HEADER {
  UInt16   'e_magic';
  UInt16   'e_cblp';
  UInt16   'e_cp';
  UInt16   'e_crlc';
  UInt16   'e_cparhdr';
  UInt16   'e_minalloc';
  UInt16   'e_maxalloc';
  UInt16   'e_ss';
  UInt16   'e_sp';
  UInt16   'e_csum';
  UInt16   'e_ip';
  UInt16   'e_cs';
  UInt16   'e_lfarlc';
  UInt16   'e_ovno';
  UInt16[] 'e_res ByValArray 4';
  UInt16   'e_oemid';
  UInt16   'e_oeminfo';
  UInt16[] 'e_res2 ByValArray 10';
  UInt32   'e_lfanew';
}

But the truth is it can create structures marked with SequentialLayout attribure only at present moment. Maybe this will be fixed by author in the future.

You can find original project at: https://github.com/gregzakharov/scope
#>
#requires -version 2.0
if (!(Test-Path alias:struct)) { Set-Alias struct Set-Structure }

function Set-Structure {
  <#
    .DESCRIPTION
        Allows to create simple structures.
    .EXAMPLE
        struct IMAGE_DOS_HEADER {
          UInt16   'e_magic';
          UInt16   'e_cblp';
          UInt16   'e_cp';
          UInt16   'e_crlc';
          UInt16   'e_cparhdr';
          UInt16   'e_minalloc';
          UInt16   'e_maxalloc';
          UInt16   'e_ss';
          UInt16   'e_sp';
          UInt16   'e_csum';
          UInt16   'e_ip';
          UInt16   'e_cs';
          UInt16   'e_lfarlc';
          UInt16   'e_ovno';
          UInt16[] 'e_res ByValArray 4';
          UInt16   'e_oemid';
          UInt16   'e_oeminfo';
          UInt16[] 'e_res2 ByValArray 10';
          UInt32   'e_lfanew';
        }
    .NOTES
        Author: greg zakharov
  #>
  [OutputType([Type])]
  param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]$StructureName,
    
    [Parameter(Mandatory=$true, Position=1)]
    [ScriptBlock]$Definition,
    
    [Parameter(Position=2)]
    [String]$AssemblyName
  )
  
  if ([String]::IsNullOrEmpty($AssemblyName)) {
    $AssemblyName = '_' + $StructureName
  }
  
  if (!(($cd = [AppDomain]::CurrentDomain).GetAssemblies() | ? {
    $_.FullName.Contains($AssemblyName)
  })) {
    $attr = 'AnsiClass, Class, Public, Sealed, SequentialLayout, BeforeFieldInit'
    $ref = $null #parsing errors
    $ctr = [Runtime.InteropServices.MarshalAsAttribute].GetConstructor(
      [Reflection.BindingFlags]20, $null, [Type[]]@([Runtime.InteropServices.UnmanagedType]), $null
    )
    $cnt = @([Runtime.InteropServices.MarshalAsAttribute].GetField('SizeConst'))
    
    $type = (($cd.DefineDynamicAssembly(
      (New-Object Reflection.AssemblyName($AssemblyName)), [Reflection.Emit.AssemblyBuilderAccess]::Run
    )).DefineDynamicModule($AssemblyName, $false)).DefineType($StructureName, $attr)
    
    [Management.Automation.PSParser]::Tokenize($Definition, [ref]$ref) | ? {
      $_.Type -match '(?:(Command)|(String))'
    } | % {
      if (($token = $_.PSBase).Type -eq 'Command') {
        $ft = [Type]$token.Content #field type
      }
      else {
        $fn = switch ($token.Content -match '\s') { #field name
          $true  {
            ($itm = $token.Content -split '\s')[0]
            $ml = $itm[1]
            $sz = $itm[2]
          }
          $false { $token.Content }
        } #switch
        
        if (!$ml -and !$sz) {
          [void]$type.DefineField($fn, $ft, 'Public')
        }
        else {
          $unm = $type.DefineField($fn, $ft, 'Public, HasFieldMarshal')
          $atr = New-Object Reflection.Emit.CustomAttributeBuilder(
            $ctr, [Runtime.InteropServices.UnmanagedType]$ml, $cnt, @([Int32]$sz)
          )
          $unm.SetCustomAttribute($atr)
        }
      } #if
      $ml = $sz = $null
    } #foreach
    
    Set-Variable $StructureName -Value $type.CreateType() -Option ReadOnly -Scope global
  } #if
}

Export-ModuleMember -Alias struct -Function Set-Structure
