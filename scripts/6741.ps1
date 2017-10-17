$ThreadTimeout = 300

#Check for jobs we can timeout
$RunningJobs = get-job -State Running
foreach($RunningJob in $RunningJobs)
{
    $CurrentTime = get-date
    $TimeoutTime = $RunningJob.PSBeginTime
    $TimeoutTime = $TimeoutTime.AddSeconds($ThreadTimeout)

    #The equation here is:
    #if the current time is more than the time the job started + 5 minutes (300 seconds)
    #then its time we get the info about the job and then stop it
    if($CurrentTime -gt $TimeoutTime)
    {
        $Log = @()
        $Log += ("Killing stuck thread " + $RunningJob.Name)
        $Log += $RunningJob.Output
        $Log += $RunningJob.Error

        echo $Log
        $Log >> $LogFileName

        #Stop the job
        $RunningJob | Stop-Job
    }                
}
