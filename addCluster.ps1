param ($AccessKey, $SecretKey)

. .\clusterManager.ps1
. .\apiReaders.ps1
. .\securityManager.ps1

$ClusterOutFile = "output\cluster\configuration.yaml"

function Register-Aws {
    Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey
    $credentialList = Get-AWSCredential -ListProfileDetail
    write-host $credentialList
}


function Start-Clika{
    param ($count)
    Register-Aws

    #create cluster
    eksctl create cluster -f $ClusterOutFile

    #add resources in cluster
    Add-ClusterResources $count
    
    #authorize to access ports of nodes
    Set-SecurityGroup -count $count

    #read apis
    Read-Apis -count $count
}

Start-Clika -count 3