### Grégory Schiro, 2009

### <summary>
### Removes diacritics from string.
### </summary>
### <param name="String">String containing diacritics</param>
function Remove-Diacritics([string]$String)
{
    ($String.Normalize([Text.NormalizationForm]::FormD)-replace'\p{Mn}').Normalize([Text.NormalizationForm]::FormC)
}
