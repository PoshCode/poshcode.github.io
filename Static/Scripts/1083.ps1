param([String] $phrase) 

$words = $phrase.Split()
$MaxLettersPerWord = 3
$output = @('')
$maxSize = [System.Math]::Pow($MaxLettersPerWord, $words.Count)

1..$words.Count | % {
	$word, $words = $words	
	$output | % {		
		$oldWord = $_
		1..$MaxLettersPerWord | % {		
			$output += $oldWord + $word.SubString(0,$_)
		}
	}		
}


$output | Select-Object -Last $maxSize
