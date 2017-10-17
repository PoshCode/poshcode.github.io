function Find-Command{
param([Parameter($Mandatory=$true)]$question)

Get-Command -Verb ($question.Split() | Where {Get-Verb $_ }) -Noun $question.Split()
}
