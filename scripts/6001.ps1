function Invoke-PowerTipsMenu
{
    function Start-PowerTipsMonthly ([int]$Volume)
    {
        [string]$urlHead = "http://powershell.com/cs/media/p"
        [string]$urlTail = "download.aspx"
        [int[]]$urlIndex = @(0, 23856, 24814, 25742, 26784, 28283, 29098,
                                29920, 30542, 31297, 32274, 33169, 38383)

        Start-Process -FilePath "$urlHead/$($urlIndex[$Volume])/$urlTail"
    }

    Import-Module -Name ReadChoice

    [string]$title  = "`nPowerTips Monthly`n" + ("="*17)
    [string]$prompt = "`nSelect PowerTips Monthly Volume(s)`n" + ("-"*34)

    "&File System Tasks",
    "&Arrays and Hash Tables",
    "&Date, Time, and Culture",
    "&Objects and Types",
    "&WMI",
    "Regular &Expressions",
    "F&unctions",
    "Static .&NET Methods",
    "&Registry",
    "&Internet-Related Tasks",
    "&XML-Related Tasks",
    "&Security-Related Tasks",
    "&Quit" | 
        Read-Choice -Title $title -Prompt $prompt -MultipleChoice |
            ForEach-Object {
                if (0..11 -contains $_)
                {
                    Start-PowerTipsMonthly -Volume ($_ + 1)
                }
            }

    Remove-Module -Name ReadChoice
}
