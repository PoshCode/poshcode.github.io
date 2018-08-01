function Pause ($Message = "Press any key to continue...")
{
	Write-Host -NoNewline $Message
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Write-Host ""
}
