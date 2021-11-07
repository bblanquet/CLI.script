# SUMMARY
contains a set of scripts to create an EKS cluster on AWS.

./createCluster.ps1
- create a VPC with 6 subnets and 3 instances **(warning: this step takes 20minutes)**
- create an EKS cluster
- deploy three instances on the EKS cluster
- set the VPC firewall to access instances
- display URLs of each instances

# RECIPE
1. install a bunch of programs
2. create an IAM user in AWS.
2. execute the script.

# STEP #1 INSTALLATION
list of required programs:
- POWERSHELL
- AWS CLI
- KUBECTL
- CHOCO (to install EKSCTL)
- EKSCTL
- AWS-POWERSHELL

### install powershell
https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi

After the installation
Run a powershell CLI as Administrator and run the below commands

### install aws CLI
>msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

### install kubectl
>curl -LO "https://dl.k8s.io/release/v1.22.0/bin/windows/amd64/kubectl.exe"

### install choco (Chocolatey is a software management solution)
>Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


### install eksctl with choco
>choco install -y eksctl

a link for more details: https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

### install AWS powershell
>**#it needs to be forced because AWS.TOOLS needs PSGallery package that is considered as untrusty by microsoft.** <br />
>Install-Module -Name AWS.Tools.Installer -Force  <br />
>Install-AWSToolsModule AWS.Tools.EC2,AWS.Tools.S3 -CleanUp  <br />

a link for more details: https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html

# STEP #2 create an IAM user
You will need to authenticate with an IAM user with enough credential.

From the below link, create a set of policies to have write/read permissions with (EC2 images, VPC and EKS cluster)

https://github.com/bibimchi/CLIKA.script/blob/master/credential/policies.txt
https://console.aws.amazon.com/iamv2/home?#/policies

Then attach all these policies to a group and  add a user to the created group.
https://console.aws.amazon.com/iamv2/home#/groups

# STEP #3 execute the script
Finally retrieve "accessKey" and the "secretKey" of the created user to execute the script</br>
example: </br>
> aws configure (set accessKey and secretKey)</br>
>.\ AddCluster.py</br>