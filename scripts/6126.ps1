param([string]$OwnerName = (Read-Host "What is the owner name?"),
      [string]$RepositoryName = (Read-Host "What is the repository name?"),
      [string]$AuthToken = (Read-Host "What is the auth token?"),
      [switch]$DeleteLabels)

$labelJson = @"
[
    {
        "name":  "priority:lowest",
        "color":  "207de5"
    },
    {
        "name":  "priority:low",
        "color":  "207de5"
    },
    {
        "name":  "priority:medium",
        "color":  "207de5"
    },
    {
        "name":  "priority:high",
        "color":  "207de5"
    },
    {
        "name":  "priority:highest",
        "color":  "207de5"
    },
    {
        "name":  "point:1",
        "color":  "009800"
    },
    {
        "name":  "point:2",
        "color":  "009800"
    },
    {
        "name":  "point:3",
        "color":  "009800"
    },
    {
        "name":  "point:5",
        "color":  "009800"
    },
    {
        "name":  "point:8",
        "color":  "009800"
    },
    {
        "name":  "point:13",
        "color":  "009800"
    },
    {
        "name":  "type:bug",
        "color":  "eb6420"
    },
    {
        "name":  "type:chore",
        "color":  "eb6420"
    },
    {
        "name":  "type:feature",
        "color":  "eb6420"
    },
    {
        "name":  "type:infrastructure",
        "color":  "eb6420"
    },
    {
        "name":  "type:performance",
        "color":  "eb6420"
    },
    {
        "name":  "type:refactor",
        "color":  "eb6420"
    },
    {
        "name":  "type:test",
        "color":  "eb6420"
    }
]

"@

$owner = $OwnerName
$repo = $RepositoryName
$headers = @{"Authorization"="token $AuthToken"}
$labelList = $labelJson | ConvertFrom-Json

function Delete-Label {
    param([string]$lableName)

    $url = "https://api.github.com/repos/{0}/{1}/labels/{2}" -f $owner, $repo, $lableName

    Invoke-WebRequest $url -Method Delete -Headers $headers
}

function Create-Label {
    param([string]$lableName, [string]$labelColor)

    $hashTable = @{"name"=$lableName; "color"=$labelColor}
    $data = $hashTable | ConvertTo-Json

    $url = "https://api.github.com/repos/{0}/{1}/labels" -f $owner, $repo

    Invoke-WebRequest $url -Method Post -Body $data -Headers $headers
}

if ($DeleteLabels) {
    foreach ($label in $labelList) {
        Write-Host "Deleting Label:" $label.name -f Yellow
        $result = Delete-Label -lableName $label.name

        if ($result.StatusCode -eq 204) {
            Write-Host $label.name "was deleted" -f DarkYellow
        } else {
            Write-Host $label.name "was not deleted" -f DarkRed
        }
    }
}

if (!$DeleteLabels) {
    foreach ($label in $labelList) {
        Write-Host "Creating Label:" $label.name -f Yellow
        $result = Create-Label -lableName $label.name -labelColor $label.color

        if ($result.StatusCode -eq 201) {
            Write-Host $label.name "was created" -f DarkYellow
        } else {
            Write-Host $label.name "was not created" -f DarkRed
        }
        
    }
}
