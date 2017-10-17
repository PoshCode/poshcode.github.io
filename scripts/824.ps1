#this is just a quite proof of concept, totally useless in of itself, with functions not fleshed out
function get-jobrepository
{
[CmdletBinding()] 
param()

$pscmdlet.JobRepository  
}
function add-job
{
[CmdletBinding()] 
param($job)
$pscmdlet.JobRepository.add($job)
}
$src = @"
using System;
using System.Collections.Generic;
using System.Text;
using System.Management.Automation;

namespace bkg2
{
    public class BackgroundJob : Job
    {
        public BackgroundJob(string command) : base(command)
        {
        }

        public string dummy = "hello";
        public override bool HasMoreData
        {
            get { return false; } //version 1 won't stream results. no results at all until job is completed
        }

        public override string Location
        {
            get { return "localhost"; } //background jobs are always in memory on the same system 
        }

        public override string StatusMessage
        {
            get { return "NO STATUS MESSAGES IMPLEMENTed YET"; }
        }

        public override void StopJob()
        {
            throw new NotImplementedException();
            
        }
    }
}
"@

add-type -typedefinition $src

1..5 | % { add-job $(new-object bkg2.BackgroundJob {1..10}) }

get-job

