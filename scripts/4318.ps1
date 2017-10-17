function foo {
param(
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
[string]
$Text
)
Get-Command -CommandType Cmdlet
Get-Process
	"bar"
	"QWERTY"
	"123"
	$Text
}

foo
