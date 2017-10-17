#requires -version 2.0

function Get-TranscriptFilePath {
    try {
      $externalHost = $host.gettype().getproperty("ExternalHost",
        [reflection.bindingflags]"nonpublic,instance").getvalue($host, @())
      $externalhost.gettype().getfield("transcriptFileName", "nonpublic,instance").getvalue($externalhost)
    } catch {
      write-warning "This host does not support transcription."
    }
}
