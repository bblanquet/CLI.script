. .\clusterManager.ps1
. .\apiReader.ps1
. .\securityManager.ps1

$ClusterOutFile = "output\cluster\configuration.yaml"

function Start-Clika{
    param ($apiCount, $nodeCount)
    
    #create cluster
    eksctl create cluster -f $ClusterOutFile

    #add resources in cluster
    Add-ClusterResources -apiCount $apiCount
    
    #authorize to access ports of nodes
    Set-SecurityGroup -count $apiCount

    #read apis
    Read-Apis -count $nodeCount
}

Start-Clika -apiCount 3 -nodeCount 3