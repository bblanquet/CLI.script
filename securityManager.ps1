$ClusterVpcTagKey = "alpha.eksctl.io/cluster-name"
$ClusterVpcTagValue = "basic-cluster"
$nodeTag = "eksctl.io/v1alpha2/nodegroup-name"

function Get-ClusterVpc{
    $vpcList = Get-EC2Vpc
    foreach($vpc in $vpcList){
        $tagValue = $vpc.Tags | Where-Object -Property Key -eq $ClusterVpcTagKey | Select-Object -ExpandProperty Value
        if($tagValue -eq $ClusterVpcTagValue){
            return $vpc
        }
    }
    return $null
}

function Set-SecurityGroup{
    param(
        $count
    )
    $minPort = 30000
    $maxPort = 30000+$count

    $vpc = Get-ClusterVpc
    $vpcGroups = Get-EC2SecurityGroup | where-object -Property VpcId -eq $vpc.VpcId
    foreach($group in $vpcGroups){
        $tag = $group.Tags | Where-Object -Property Key -Eq $nodeTag | select-object -ExpandProperty Value
        if($tag -match 'ng'){
            #authorize to access the ports 3000 to 3000+count for each node
            #it's dirty best way would be to implement a load balancing
            #instead of using nodeport service
            write-host edit security group: $group.GroupId with tag: $tag to get access from $minPort to $maxPort ports
            $ip1 = @{ IpProtocol="tcp"; FromPort=$minPort; ToPort=$maxPort; IpRanges="0.0.0.0/0" }
            Grant-EC2SecurityGroupIngress -GroupId $group.GroupId -IpPermission @( $ip1 )
        }
    }
}