param($cluster)
gwmi -ComputerName $cluster -Namespace "root\mscluster" -Class MSCluster_Resource | Select @{n='Cluster';e={$cluster}},Name, RestartAction
