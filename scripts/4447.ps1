param
(
	[Parameter(Mandatory=$True)]
	@@[ValidateScript({$_ -match [IPAddress]$_ })]
	[String]$ip
)
