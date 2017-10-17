### Grégory Schiro, 2009

### <summary>
### Removes diacritics from string.
### </summary>
### <param name="String">String containing diacritics</param>
function Remove-Diacritics([string]$String)
{
    $objD = $String.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder

    for ($i = 0; $i -lt $objD.Length; $i++) {
        $c = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($objD[$i])
        if($c -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
          [void]$sb.Append($objD[$i])
        }
      }

    return("$sb".Normalize([Text.NormalizationForm]::FormC))
}
