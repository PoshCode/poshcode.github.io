#requires -modules GroupPolicy
param([String]$Computer = 'localhost', [String]$User, [Microsoft.GroupPolicy.ReportType]$ReportType = 'XML')
$gprsop = new-object Microsoft.GroupPolicy.GPRsop([Microsoft.GroupPolicy.RsopMode]::Logging,'')
$gprsop.LoggingComputer = $Computer
if ($PSBoundParameters.ContainsKey('User')) {
	$gprsop.LoggingUser = $User
}
$gprsop.CreateQueryResults()
$report = $gprsop.GenerateReport($ReportType)
if ($ReportType -eq 'XML') {
    return [xml]$report
}
return $report

