([Regex]"(?<=\.\s)(.*)(?=\-)").Match(
  $(route print | ? {$_ -match ((arp -a | ? {$_ -match '0x'}) -split ' ')[-1]})
).Value
