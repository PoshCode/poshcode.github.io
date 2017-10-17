foreach
($ExchangServer in (Get-ExchangeServer | Where { $_.isHubTransportServer -eq $True})) 
{Get-queue -Server $ExchangeServer}


