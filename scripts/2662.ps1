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
   
   if($WithArgs -and -not $ParameterTypes) {
      $ParameterTypes = $withArgs | % { $_.GetType() }
   } elseif(!$ParameterTypes) {
      $ParameterTypes = [Type]::EmptyTypes
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

                                    $Accept = $ParameterTypes.Count -eq $Parameters.Count
            Write-Verbose "  $Accept = $($Parameters.Count) Arguments"
            if($Accept) {
               for($i=0;$i -lt $Parameters.Count;$i++) {
                  $Accept = $Accept -and ( $Parameters[$i].IsGeneric -or ($ParameterTypes[$i] -eq $Parameters[$i].ParameterType))
                  Write-Verbose "   $Accept =$(if($Parameters[$i].IsGeneric){' GENERIC or'}) $($ParameterTypes[$i]) -eq $($Parameters[$i].ParameterType)"
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
   for($i=0;$i -lt $ParameterTypes.Count;$i++){
      Write-Verbose "$($ParameterTypes[$i]) ? $($ConcreteTypes[$i] -eq $ParameterTypes[$i])"
      if($ConcreteTypes[$i] -ne $ParameterTypes[$i]) {
         $GenericParameters += $ParameterTypes[$i]
      }
      $ParameterTypes[$i] = Add-Member -in $ParameterTypes[$i] -Type NoteProperty -Name IsGeneric -Value $($ConcreteTypes[$i] -ne $ParameterTypes[$i]) -Passthru
   }
   
    $ParameterTypes | Where-Object { $_.IsGeneric }
   Write-Verbose "$($GenericParameters -join ', ') generic parameters"
      
   $MemberInfo = $MemberInfo.MakeGenericMethod( $GenericParameters )
   Write-Verbose $MemberInfo
   
   if($WithArgs) {
      [Object[]]$Arguments = $withArgs | %{ $_.PSObject.BaseObject }
      Write-Verbose "Arguments: $(($Arguments | %{ $_.GetType().Name }) -Join ', ')"
      $MemberInfo.Invoke( $InputObject, $Arguments )
   } else {
      $MemberInfo.Invoke( $InputObject )
   }
} }
