function Get-Sp1Articles() 
{ 
    $web = New-Object System.Net.WebClient 
    # Microsoft XLS-Datei über google herunterladen, damit kommt die XLS-Datei als in HTML konvertierte Datei
    $html = $web.DownloadString(‘http://webcache.googleusercontent.com/search?q=cache:trZowCK8jvcJ:download.microsoft.com/download/8/B/3/8B37425B-AB6E-4C9C-9361-ECC15771BC5C/Hotfixes%2520and%2520Security%2520Updates%2520included%2520in%2520Windows%25207%2520and%2520Windows%2520Server%25202008%2520R2%2520Service%2520Pack%25201.xls’)
    # zuerst den Google Header und das unnötige Blabla wegbekommen 
    $html = $html.Substring($html.IndexOf("KBTitle")) 
    # jetzt das nächste <tr> finden 
    $html = $html.Substring($html.IndexOf("<tr")) 
    # einzelne Zeile mit KB-Eintrag erkennen 
    $regex = ‘<tr([\s\S]*?)</tr>’

    # HTML in Objektauflistung überführen 
    ($html |Select-String -Pattern $regex -AllMatches).matches |foreach { 
                    # durch überführen in ein XML-Objekt läßt sich die Zeile leichter verarbeiten 
                    [xml]$tmp = $_ 
                    # neues Objekt erzeugen, dem die 4 wichtigen Eigenschaften zugeordnet werden, wenn eine KB-Nummer eingetragen ist 
                    if ($tmp.tr.td[0].font.’#text’ -gt 0) 
                    { 
                        $obj = New-Object psobject 
                        $obj |Add-Member -MemberType NoteProperty -Name KBArticle -Value $tmp.tr.td[0].font.’#text’ 
                        $obj |Add-Member -MemberType NoteProperty -Name Classification -Value $tmp.tr.td[1].font.’#text’ 
                        $obj |Add-Member -MemberType NoteProperty -Name KBTitle -Value $tmp.tr.td[2].font.’#text’ 
                        $obj |Add-Member -MemberType NoteProperty -Name Link -Value $tmp.tr.td[3].a.href 
                        $obj 
                    } 
                } 
}
