function Get-GitInfoForDirectory {

    param (
    )

    begin {
        $gitBranch = (git branch)
        $gitStatus = (git status)
        $gitTextLine = ""
    }

    process {
        try {
            foreach ($branch in $gitBranch) {
                if ($branch -match '^\* (.*)') {
                    $gitBranchName = 'Git Repo - Branch: ' + $matches[1].ToUpper()
    	        }
            }
    
            if (!($gitStatus -like '*working directory clean*')) {
                $gitStatusMark = ' ' + '/' + ' Status: ' + 'NEEDS UPDATING'
            }
            elseif ($gitStatus -like '*Your branch is ahead*') {
                $gitStatusMark = ' ' + '/' + ' Status: ' + 'PUBLISH COMMITS'
            }
            else {
                $gitStatusMark = ' ' + '/' + ' Status: ' + 'UP TO DATE'
            }
        }
        catch {
        }
    }

    end {
        if ($gitBranch) { 
            $gitTextLine = ' {' + $gitBranchName + $gitStatusMark + '}'            
        }
        return $gitTextLine       
    }    
}
