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

namespace bkg1
{
    public class BackgroundJob : Job
    {
        public BackgroundJob(string command) : base(command)
        {
        }
        
        public override bool HasMoreData
        {
            get { throw new NotImplementedException(); }
        }

        public override string Location
        {
            get { throw new NotImplementedException(); }
        }

        public override string StatusMessage
        {
            get { throw new NotImplementedException(); }
        }

        public override void StopJob()
        {
            throw new NotImplementedException();
        }
    }
}

"@

add-type -typedefinition $src

$a = new-object bkg1.BackgroundJob {1..10}
add-job $a
get-job
