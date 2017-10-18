# For example I have this function

function copySourceDestination {
	Param (
	 	[string]$sourceFile,
		[string]$destinationPath
	)

# Strangely enough $sourceFile will contain both the values of $sourceFile and $destinationPath
# in this case $destinationPath will be empty and $sourceFile will show up as: "C:\bla.txt \\server\share\path"

	Copy-Item -Path:$sourceFile -Destination:$destinationPath -Force
}


# Calling the function
copySourceDestination "C:\bla.txt" "\\server\share\path"
