$serviceName = "api-service-"
$namespace = "clika"

$ServiceInFile = "input\api\service.yaml"
$ServiceOutFile = "output\api\service.yaml"

$DeploymentInFile = "input\api\deployment.yaml"
$DeploymentOutFile = "output\api\deployment.yaml"

$ConfigMapInFile = "input\api\configMap.yaml"
$ConfigMapOutFile = "output\api\configMap.yaml"

$NamespaceOutFile = "output\api\namespace.yaml"

#create namespace
function Add-Namespace{
    kubectl apply -f $NamespaceOutFile
}

#/////// edit files START
function Set-ConfigMapFile {
    param (
        $port,
        $ip,
        $list
    )
    Write-Host set configmap file with $port - $ip - $list
    (Get-Content $ConfigMapInFile).replace('{{port}}', $port).`
    replace('{{ip}}', $ip).`
    replace('{{list}}', $list) | Set-Content $ConfigMapOutFile
    write-host updated $ConfigMapOutFile
}

function Set-DeploymentFile {
    param (
        $port
    )
    Write-Host set deployment file with $port
    (Get-Content $DeploymentInFile).replace('{{port}}', $port) | Set-Content $DeploymentOutFile
    write-host updated $DeploymentOutFile
}

function Set-ServiceFile {
    param (
        $port
    )
    Write-Host set service file with $port
    (Get-Content $ServiceInFile).replace('{{port}}', $port) | Set-Content $ServiceOutFile
    write-host updated $ServiceOutFile
}

# /////// edit files END


function Add-ClusterService{
    param( $port)
    Set-ServiceFile -port $port
    kubectl apply -f $ServiceOutFile
}

function Get-ClusterServiceIp{
    param ($serviceName)
    $ip = (kubectl --namespace $namespace -o json get service $serviceName | ConvertFrom-Json).spec.clusterIP
    return $ip
}

function Add-ClusterResources{
    param(
        $count
    )
    $ips = @()

    #add namespace
    Add-Namespace

    #add services and store ip addresses
    for($i=1; $i -le $count; $i++){
        $port = 30000+$i
        Add-ClusterService -port $port
        $ip = Get-ClusterServiceIp -serviceName (-join($serviceName,$port))
        $ips = $ips + @($ip)
    }

    # deploy APIs
    for($i=1; $i -le $count; $i++){
        $port = 30000+$i
        Set-ConfigMapFile -port $port -ip $ips[$i-1] -list ($ips -join ',')
        kubectl apply -f $ConfigMapOutFile

        Set-DeploymentFile -port $port
        kubectl apply -f $DeploymentOutFile
    }
}