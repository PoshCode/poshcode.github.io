Set-StrictMode -Version latest

$script:hex = '0123456789ABCDEF'

function script:CopyStart($int, $buf) {
	$i = 7
	do {
		$buf[$i--] = $script:hex[$int -band 0xF]
	} while ($int = $int -shr 4)
}

function Format-HexDump {
#.Synopsis
#  Rudimentry hex dumper.
#.Example
#  . { 0..0xFF ; 'asdf' ; 0..0x10 } | Format-HexDump
	[CmdletBinding()]
	param(
		[Parameter(Position = 0)]
		[uint32]$Base = 0
,
		[Parameter(ValueFromPipeline)]
		$InputObject
,
		[switch]$Skip
	)
	begin {
		''
		' Address:   0  1  2  3  4  5  6  7- 8  9  A  B  C  D  E  F  ASCII'
		'--------:---------------------------------------------------================'
		$buf = New-Object char[] 76
		foreach ($i in 9..75) {
			$buf[$i] = [char]' '
		}
		$i = if ($Skip) { $Base % 16 } else { 0 }
		$offset = -$i
		CopyStart ($Base+$offset) $buf
		$buf[8] = [char]':'
		$buf[34] = [char]'-'
	}
	process {
		$bytes = if ($InputObject -isnot [string]) { $InputObject -as [byte[]] } else { $null }
		if ($null -eq $bytes) {
			$bytes = [Text.Encoding]::UTF8.GetBytes([string]$InputObject)
		}
		foreach ($b in $bytes) {
			$buf[$i*3 + 11] = $script:hex[$b -shr 4]
			$buf[$i*3 + 12] = $script:hex[$b -band 0xF]
			$buf[$i + 60] = if ((31 -lt $b) -and (127 -gt $b)) { [char]$b } else { [char]'.' }

			if (16 -eq ++$i) {
				New-Object string (,$buf)
				$offset += 16
				$i = 0
				CopyStart ($Base+$offset) $buf
			}
		}
	}
	end {
		if (0 -ne $i -or (($Base+$offset) -eq ($Base+$i))) {
			foreach ($b in $i..15) {
				$buf[$b*3 + 11] = [char]' '
				$buf[$b*3 + 12] = [char]' '
			}
			if (8 -ge $i) {
				$buf[34] = [char]' '
			}
			New-Object string $buf,0,(60+$i)
		}
		''
	}
}

