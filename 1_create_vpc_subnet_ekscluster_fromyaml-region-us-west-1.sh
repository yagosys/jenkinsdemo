clustername="eks-cluster-3"

regionname="us-west-1"
vpccidr="10.3.0.0/16"
sub="10-3"
pub01="10.3.1.0/24"
pub02="10.3.2.0/24"
pri01="10.3.3.0/24"
pri02="10.3.4.0/24"

if ( aws cloudformation describe-stacks --stack-name=$clustername --query 'Stacks[0].StackStatus' --output=text ); then

   echo "there are already have a stack called $clustername"

else (
      	echo "begin to create stack" ;
	aws cloudformation create-stack --region $regionname --stack-name $clustername --template-url https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml --parameters ParameterKey=PublicSubnet01Block,ParameterValue=$pub01 ParameterKey=PublicSubnet02Block,ParameterValue=$pub02 ParameterKey=PrivateSubnet01Block,ParameterValue=$pri01 ParameterKey=PrivateSubnet02Block,ParameterValue=$pri02 ParameterKey=VpcBlock,ParameterValue=$vpccidr )

fi

echo "to delete , use aws cloudformation delete-stack --stack-name $clustername"
echo "vpc name is stackname-vpc which is $clustername-VPC"
echo "wait for stack to complete"
aws cloudformation wait stack-create-complete --stack-name $clustername --region $regionname

echo "get subnet id"

ekspub01=`aws ec2 describe-subnets --region $regionname --filters "Name=tag:Name, Values=$clustername-PublicSubnet01" | grep SubnetId | cut -d '"' -f 4`
echo ekspub01=$ekspub01
ekspub02=`aws ec2 describe-subnets --region $regionname --filters "Name=tag:Name, Values=$clustername-PublicSubnet02" | grep SubnetId | cut -d '"' -f 4`
echo ekspub02=$ekspub02
ekspri01=`aws ec2 describe-subnets --region $regionname --filters "Name=tag:Name, Values=$clustername-PrivateSubnet01" | grep SubnetId | cut -d '"' -f 4`
echo ekspri01=$ekspri01
ekspri02=`aws ec2 describe-subnets --region $regionname --filters "Name=tag:Name, Values=$clustername-PrivateSubnet02" | grep SubnetId | cut -d '"' -f 4`
echo ekspri02=$ekspri02

vpcId=`aws ec2 describe-vpcs --region $regionname --filters "Name=tag:Name, Values=$clustername-VPC" | grep VpcId | cut -d '"' -f 4`
echo $vpcId
echo "now start create cluster with eksctl on vpc $vpcId, on region $regionname, clustername $clustername, cidr $vpccidr "

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
cat <<EOF | eksctl create cluster  -f -
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $clustername
  version: "1.18"
  region: $regionname

addons:
- name: vpc-cni
  attachPolicyARNs:
    - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

vpc:
  id: $vpcId
  cidr: $vpccidr
  nat:
    gateway: disable 
  clusterEndpoints:
    publicAccess: true
    privateAccess: true
  subnets:
    public:
      az1-$sub-1-pub:
        id: $ekspub01
        cidr: $pub01
      az1-$sub-3-pri:
        id: $ekspri01
        cidr: $pri01
      az2-$sub-2-pub:
        id: $ekspub02
        cidr: $pub02
      az2-$sub-4-pri:
        id: $ekspri02
        cidr: $pri02
nodeGroups: 
  - name: ng-$clustername
    labels: { role: workers , owner: andy}
    minSize: 1
    maxSize: 2 
    subnets: 
      - az1-$sub-3-pri
      - az2-$sub-4-pri
    instanceType: m5.large
    desiredCapacity: 1
    volumeSize: 32
    ssh:
      allow: true
      publicKeyPath: ~/.ssh/id_rsa.pub
    securityGroups:
      withShared: true
      withLocal: true
    tags:
      'owner': 'andy'
      nodegroup-role: worker
EOF
