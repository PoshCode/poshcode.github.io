function Get-Payment {
	param ( $LoanAmount, [double]$InterestRatePerPeriod, $NumberPayments )
	$a = $LoanAmount
	$b = $InterestRatePerPeriod*[math]::Pow(($InterestRatePerPeriod + 1),$NumberPayments)
	$c = [math]::Pow((1+$InterestRatePerPeriod),$NumberPayments) - 1
	$payment = $a*($b/$c)
	"{0:C}" -f $payment
}
