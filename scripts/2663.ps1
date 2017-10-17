function Invoke-Generic {
#.Synopsis
#  Invoke Generic method definitions via reflection:
[CmdletBinding()]
param( 
   [Parameter(Position=0,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias('On')]
   $InputObject
,
   [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
   [Alias('Named')]
   [string]$MethodName
,
   [Parameter(Position=2)]
   [Alias("Types")]
   [Type[]]$ParameterType
, 
   [Parameter(Position=4, ValueFromRemainingArguments=$true, ValueFromPipelineByPropertyName=$true)]
   [Alias("Args")]
   [Object[]]$ArgumentList
,
   [Switch]$Static
)
begin {
   if($Static) {
      $BindingFlags = [System.Reflection.BindingFlags]"IgnoreCase,Public,Static"
   } else {
      $BindingFlags = [System.Reflection.BindingFlags]"IgnoreCase,Public,Instance"
   }
}
process {
   $Type = $InputObject -as [Type]
   if(!$Type) { $Type = $InputObject.GetType() }
   
   if($ArgumentList -and -not $ParameterType) {
      $ParameterType = $ArgumentList | % { $_.GetType() }
   } elseif(!$ParameterType) {
      $ParameterType = [Type]::EmptyTypes
   }   
   
   
   trap { continue }
   $MemberInfo = $Type.GetMethod($MethodName, $BindingFlags)
   if(!$MemberInfo) {
      $MemberInfo = $Type.GetMethod($MethodName, $BindingFlags, $null, $NonGenericArgumentTypes, $null)
   }
   if(!$MemberInfo) {
      $MemberInfo = $Type.GetMethods($BindingFlags) | Where-Object {
         $MI = $_
         [bool]$Accept = $MI.Name -eq $MethodName
         if($Accept){
         Write-Verbose "$Accept = $($MI.Name) -eq $($MethodName)"
            [Array]$GenericTypes = @($MI.GetGenericArguments() | Select -Expand Name)
            [Array]$Parameters = @($MI.GetParameters() | Add-Member ScriptProperty -Name IsGeneric -Value { 
                                       $GenericTypes -Contains $this.ParameterType 
                                    } -Passthru)

                                    $Accept = $ParameterType.Count -eq $Parameters.Count
            Write-Verbose "  $Accept = $($Parameters.Count) Arguments"
            if($Accept) {
               for($i=0;$i -lt $Parameters.Count;$i++) {
                  $Accept = $Accept -and ( $Parameters[$i].IsGeneric -or ($ParameterType[$i] -eq $Parameters[$i].ParameterType))
                  Write-Verbose "   $Accept =$(if($Parameters[$i].IsGeneric){' GENERIC or'}) $($ParameterType[$i]) -eq $($Parameters[$i].ParameterType)"
               }
            }
         }
         return $Accept
      } | Sort { @($_.GetGenericArguments()).Count } | Select -First 1
   }
   Write-Verbose "Time to make generic methods."
   Write-Verbose $MemberInfo
   [Type[]]$GenericParameters = @()
   [Array]$ConcreteTypes = @($MemberInfo.GetParameters() | Select -Expand ParameterType)
   for($i=0;$i -lt $ParameterType.Count;$i++){
      Write-Verbose "$($ParameterType[$i]) ? $($ConcreteTypes[$i] -eq $ParameterType[$i])"
      if($ConcreteTypes[$i] -ne $ParameterType[$i]) {
         $GenericParameters += $ParameterType[$i]
      }
      $ParameterType[$i] = Add-Member -in $ParameterType[$i] -Type NoteProperty -Name IsGeneric -Value $($ConcreteTypes[$i] -ne $ParameterType[$i]) -Passthru
   }
   
    $ParameterType | Where-Object { $_.IsGeneric }
   Write-Verbose "$($GenericParameters -join ', ') generic parameters"
      
   $MemberInfo = $MemberInfo.MakeGenericMethod( $GenericParameters )
   Write-Verbose $MemberInfo
   
   if($ArgumentList) {
      [Object[]]$Arguments = $ArgumentList | %{ $_.PSObject.BaseObject }
      Write-Verbose "Arguments: $(($Arguments | %{ $_.GetType().Name }) -Join ', ')"
      $MemberInfo.Invoke( $InputObject, $Arguments )
   } else {
      $MemberInfo.Invoke( $InputObject )
   }
} }
