param (
    [System.Data.SqlClient.ApplicationIntent]$ApplicationIntent,
    [string]$ApplicationName,
    [switch]$AsynchronousProcessing,
    [string]$AttachDBFilename,
    [switch]$ConnectionReset,
    [string]$ConnectionString,
    [int]$ConnectRetryCount,
    [int]$ConnectRetryInterval,
    [int]$ConnectTimeout,
    [switch]$ContextConnection,
    [string]$CurrentLanguage,
    [string]$DataSource,
    [switch]$Encrypt,
    [switch]$Enlist,
    [string]$FailoverPartner,
    [string]$InitialCatalog,
    [switch]$IntegratedSecurity,
    [int]$LoadBalanceTimeout,
    [int]$MaxPoolSize,
    [int]$MinPoolSize,
    [switch]$MultipleActiveResultSets,
    [switch]$MultiSubnetFailover,
    [string]$NetworkLibrary,
    [int]$PacketSize,
    [string]$Password,
    [switch]$PersistSecurityInfo,
    [switch]$Pooling,
    [switch]$Replication,
    [string]$TransactionBinding,
    [switch]$TrustServerCertificate,
    [string]$TypeSystemVersion,
    [string]$UserID,
    [switch]$UserInstance,
    [string]$WorkstationID,
    [Switch]$AsBuilder
)

if ($PSBoundParameters.ContainsKey('AsBuilder')) {
    $PSBoundParameters.Remove('AsBuilder') | Out-Null
}

$Builder = New-Object -TypeName System.Data.SqlClient.SqlConnectionStringBuilder -Property $PSBoundParameters

if($AsBuilder) {
    $Builder
} else {
    $Builder.ConnectionString
}
