function Speak-Text
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$text
    )

    Begin
    {
        $speaker = New-Object -com SAPI.SpVoice
    }
    Process
    {
        $speaker.Speak($text)
    }
    End
    {
        $speaker.Dispose()
    }
}

Write-Output "Checking if Wi-Fi is working ... ?"
$Test = (Test-Connection -Quiet plkon-nt7000)
Write-Output "... $Test"
if ($Test -eq $False) {
    Speak-Text "Och nie, chyba nie mam po³¹czenia do systemu N te 7000"
    Restart-NetAdapter -Name Wi-Fi
    Start-Sleep 5
    netsh wlan connect name=mcn-forklift 
    Speak-Text "Nie martw siê, pracuj dalej, zrestartowa³am za ciebie po³¹czenie z bezprzewodówk¹, bo wiem ¿e masz wa¿niejsze sprawy na g³owie"

}

# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# -command "& 'C:\Scripts\s_Restart-WiFi.ps1'
