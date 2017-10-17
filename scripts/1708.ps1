# Personally, I use this as a script (just save in your path as Out-Posh.ps1, and delete all but the middle line (that starts with "end")
function out-posh {
end { New-BootsWindow { $input } -inline }
}

