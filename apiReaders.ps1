$namespace = "clika"

function Get-NodeNames {
    param (
        $count
    )
    $names = @()
    for($i=1; $i -le $count; $i++){
        $names = $names + @((kubectl -o json get nodes | ConvertFrom-Json).items[$i-1].metadata.name)
    }
    return $names
}

function Get-NodeAddress{
    param ($nodeName)
    return (kubectl -o json get node $nodeName | ConvertFrom-Json).status.addresses `
    | where-object -Property type -EQ ExternalIP `
    | select-object -ExpandProperty address
}

function Get-ApiList {
    write-host retrieving api urls... it may take a few seconds 
    $nodeNames = Get-NodeNames -count 3
    $apiList = @()
    foreach ($nodeName in $nodeNames) {
        $nodeAddress = Get-NodeAddress $nodeName 
        $nodePods = (kubectl get pod --namespace $namespace -o json --field-selector spec.nodeName=$nodeName | ConvertFrom-Json).items
        foreach ($pod in $nodePods) {
            $nodePort = ($pod.metadata.labels.app).replace('api-','')
            $apiList = $apiList + @(-join($nodeAddress,':',$nodePort))
        }
    }
    return $apiList;
}

function Read-Urls {
    param($api)
    write-host (-join('http://',$api,'/communication/broadcast'));
    write-host (-join('http://',$api,'/communication/ping'));
    write-host (-join('http://',$api,'/communication/send?ip='));
    write-host --------------------;
}

function Read-Apis{
    param(
        $count
    )
    foreach($api in (Get-ApiList -count $count)){
        Read-Urls $api
    }
}