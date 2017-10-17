Add-Type -Path (Join-Path (Split-Path $Profile) Libraries\LoreSoft.MathExpressions.dll)
## You can dot-source this in 1.0 after uncommenting the following line, and deleting the first and last lines.
# [Reflection.Assembly]::LoadFrom((Join-Path (Split-Path $Profile) Libraries\LoreSoft.MathExpressions.dll)) | Out-Null

$MathEvaluator = New-Object LoreSoft.MathExpressions.MathEvaluator

Function Use-Math {
   $MathEvaluator.Evaluate( ($args -join " ") )
}

Set-Alias Math Use-Math

Export-ModuleMember -Function * -Alias * 
