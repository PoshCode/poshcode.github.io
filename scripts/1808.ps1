param ([string]$recursePath= $(Throw "Du må spesifisere ei mappe!"))

function build-word-docs($recursePath) {
    # $dir = "C:\Users\bjorninge\Documents\My Dropbox\mafo-bjorn\bachelor-prosjekt\Driftsdokumentasjon"
    $oldDir = get-location
    cd $recursePath
    $files = ls -Recurse | where {$_.extension.endsWith(".docx")}

    $word = new-object -com word.application
    $word.Visible = $false

    $word.Documents.Add() | out-null

    $selection = $word.Selection

    $i = 0
    $count = $files.count

    write-host "Totalt antall .docx-filer funnet: " $count
    foreach($file in $files) {
      
      $selection.InsertFile($file.fullname)
      $selection.InsertBreak()
      $i++
      Write-Progress -activity "Filinnsetting" -status "Filer lagt til i Word-dokumentet : " -PercentComplete (($i / $count)  * 100) 

    }
    cd $oldDir
    $word.Visible = $true

}

if( (test-path -literalpath $recursePath -pathtype container)) {
    build-word-docs $recursePath

}  else {
    write-host "Innskrevet mappesti var ikke gyldig"
}
