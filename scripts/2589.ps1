$url = "http://dougfinke.com/scriptinggames/scriptinggames.html"
$web = New-Object System.Net.WebClient

foreach($line in ($web.downloadString($url)).split("`n")){
    if($line -match "img"){ 
        $line
        $fileName = $line.substring($line.indexof("title=")+7,(($line.indexof(" src"))-1)-($line.indexof("title=")+7))
        $fileName = $fileName.replace(" ","_")
        $fileName
        
        $URLpath = $line.substring($line.indexof("src=")+5,(($line.indexof(">"))-1)-($line.indexof("src=")+5))
        $URLpath
        $web.DownloadFile($URLpath,"C:\Users\Public\Pictures\Twitter\$fileName.jpg")
    }
}


