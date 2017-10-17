param(
    $projectDirectoryName = "MyProject"
    )
$thisDir = Split-Path $MyInvocation.MyCommand.Path
$projectDir = "$thisDir/../$projectDirectoryName"

$csproj = [xml](cat $projectDir/*.csproj)
$csprojScripts = $csproj.Project.ItemGroup.Content.Include | ? {$_ -match '\.js$'}
"$($csprojScripts.length) scripts included in csproj file"

$scripts = ls $projectDir -rec -inc *.js
$scripts = $scripts.FullName | % {($_ -match "$projectDirectoryName\\(.*)" | out-null); $matches[1]}
"$($scripts.length) scripts contained in scripts directory"

$diff = $scripts |? {-not ($csprojScripts -contains $_)}
"Scripts in directory but not in csproj:"
$diff

return $diff.length
