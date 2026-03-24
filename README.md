### This project is for the Devops Bootcamp Exercise for "Infrastructure as Code with Terraform" 

#### IMPORTANT - please read the following:

##### EBS CSI Driver
Since K8s version 1.23 an additional driver is required to provision K8s storage in AWS. K8s volumes attach to cloud platform's storage - for AWS this means they attach to EBS volumes. The EBS CSI driver is responsible for handling EBS storage tasks and is not installed by default so without the installation of this driver, K8s volumes cannot be attached to storage in AWS. 

Processes on the node group nodes are responsible for creating and attaching these volumes. Because of that, we need to add a permissions policy to the node group so it can request these changes through AWS - this is defined as a managed AWS policy called: AmazonEBSCSIDriverPolicy, which we are attaching to the node groups.

So the following 2 code snippets must be added to your EKS Terraform file to make sure EBS CSI driver is activated and the node group nodes have the needed permissions:

```sh
# 1. Including the add-on as part of EKS module:

cluster_addons = {
    aws-ebs-csi-driver = {}
}

# 2. Adding associated permissions as part of node group configuration:

iam_role_additional_policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
```

##### MySQL EKS Dependency

An additional dependency is also required to be defined in your MySQL Terraform configuration. Use the following to ensure that Terraform waits for the EKS cluster to be fully created before provisioning dependent resources

```sh
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

```

**Versions:**
- Terraform: v1.6.1
- eks module: 19.20.0
- vpc module: 5.2.0
- helm provider: v2.11.0 
- aws provider: v5.26.0
- kubernetes provider: v2.23.0
- ebs csi driver: v1.25.0

**Create S3 bucket:** 
- name: "my-bucket-exercise"
- region: eu-central-1

**Set variables:**
- env_prefix = "dev"
- k8s_version = "1.28"
- cluster_name = "my-cluster"
- region = "eu-central-1"

To execute the TF script:
```
terraform init

terraform apply -var-file="dev.tfvars"

```

## Create EKS Cluster without using module 

### Create VPC for Workder Nodes

#### Create VPC 

Use `resource "aws_vpc" ""` to create a VPC

```
resource "aws_subnet" "eks-public-subnet-1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.0.0/18"
    availability_zone = "us-west-1a"

    tags = {
        Name = "eks-public-subnet-1"
    }
}
```

#### Create 2 Public Subnets 2 Privates Subnets 

For High Availability and DR : I create 2 PL/PV Subnets in each AZ (Should be 3 each)

Use `resource "aws_subnet" ""` to create Subnets

```
resource "aws_subnet" "eks-public-subnet-1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.0.0/18"
    availability_zone = "us-west-1a"

    tags = {
        Name = "eks-public-subnet-1"
    }
}
```

Same thing for other Subnet 

#### Create a Internet Gateway  in VPC 

Need a IGW to connect to a Internet 

```
resource "aws_internet_gateway" "eks-igw" {
    vpc_id = aws_vpc.eks-vpc.id
    tags = {
        Name = "eks-igw"
    }
}
```

#### Create for NAT Gateway 

Each NAT need a `Elastic IP` so I create 2 EIP for 2 NAT Gateway: 

```
resource "aws_eip" "nat-eip-1" {
  domain = "vpc"
}
```

Then create NAT Gateway : 

```
resource "aws_nat_gateway" "eks-nat-gateway-1" {
  allocation_id = aws_eip.nat-eip-1.id
  subnet_id     = aws_subnet.eks-public-subnet-1.id 
  tags = {
    Name = "gw NAT public subnet 1"
  }
}
```

#### Create Route Table for with Public Subnet and Associate to Public Subnet

Route table help traffics know where to go 

If traffic go to this `Destination` go to this `Path`

This route table associate with `IWG`

```
resource "aws_route_table" "eks-rtb-public" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name = "rtb public"
  }
}

### Associate Route Table with Public Subnets

resource "aws_route_table_association" "eks-rtb-public-association-1" {
  subnet_id = aws_subnet.eks-public-subnet-1.id
  route_table_id = aws_route_table.eks-rtb-public.id
}   

resource "aws_route_table_association" "eks-rtb-public-association-2" {
  subnet_id = aws_subnet.eks-public-subnet-2.id
  route_table_id = aws_route_table.eks-rtb-public.id
}
```

#### Create 2 more table for Privates Subnet

This Route table associate with `NAT Gateway` 

```
resource "aws_route_table" "eks-rtb-private-1" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gateway-1.id
  }

  tags = {
    Name = "rtb private 1"
  }
}

resource "aws_route_table" "eks-rtb-private-2" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat-gateway-2.id
  }

  tags = {
    Name = "rtb private 2"
  }
}
```

```
resource "aws_route_table_association" "eks-rtb-private-association-1" {
  subnet_id = aws_subnet.eks-private-subnet-1.id
  route_table_id = aws_route_table.eks-rtb-private-1.id
}

resource "aws_route_table_association" "eks-rtb-private-association-2" {
  subnet_id = aws_subnet.eks-private-subnet-2.id
  route_table_id = aws_route_table.eks-rtb-private-2.id
}
```

### Create EKS Cluster 

#### Fetch nessessary created Role by using data

First Role is for EKS Cluster to manage and do stuff on my AWS account on my behalf 

Second Role is for my Worker Nodes to call various API on my AWS Account (like call ECR to get Image) 

Third Role is for my Cluster Auto Scaler to scale up and down my Nodes

```
data "aws_iam_role" "eks-role" {
    name = "EKS-Role"
}

data "aws_iam_role" "eks-managed-node-group-role" {
    name = "EKS-Managed-Node-Group"
}

data "aws_iam_role" "cluster-autoscaler-role" {
    name = "Pod-Identity-Cluster-Auto-Scaler"
}
```

#### Create EKS Cluster by using resource

Set up EKS role for my EKS Cluster 

Associate with my created VPC above 

- `PV endpoint`: Is for AWS Managed control Plan to communicate with my Worker Nodes in my VPC 

- `PL endpoint` : Is for me as a developer to interact with a Cluster using `kubectl`

- Only put Private Subnet for my Cluster bcs I want all my Worker Nodes to deploy in a Private Subner (For Security)

- Public Subnet is for NAT Gateway, Load Balancer ...

```
resource "aws_eks_cluster" "eks-cluster" {
    name = "eks-cluster"
    role_arn = data.aws_iam_role.eks-role.arn
    version = "1.35"

    vpc_config {
        endpoint_private_access = true
        endpoint_public_access  = true

        subnet_ids = [
            aws_subnet.eks-private-subnet-1.id,
            aws_subnet.eks-private-subnet-2.id
        ]
    }

    access_config {
      authentication_mode = "API"
    }



    tags = {
        Name = "eks-cluster"
    }
}
```

#### Create EKS Managed Node Group 

EKS Managed Node group is AWS take care of (kubelet, container registry ...) and I still can interact with my Worker Nodes

Set up Role for my Managed Worker Nodes

Deploy in Private Subnet

Set up ASG min, max, desired for my EKS Cluster

`update_config`: For when AWS need to update my nodes 

```
resource "aws_eks_node_group" "eks-managed-node-group" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = "eks-managed-node-group"

    node_role_arn = data.aws_iam_role.eks-managed-node-group-role.arn
    
    subnet_ids = [
        aws_subnet.eks-private-subnet-1.id,
        aws_subnet.eks-private-subnet-2.id
    ]

    scaling_config {
        desired_size = 2
        max_size = 3
        min_size = 1
    }

    update_config {
      max_unavailable = 1
    }
}
```

#### Create Addon 

`vpc-cni`: Container Network Interface It enables Kubernetes Pods to get real IP addresses from the VPC, allowing them to communicate directly over the VPC network.

`core-dns` : DNS solution for my Kubernetes Cluster

`kube-proxy`: Send traffic from Service to Pod 

`metrics-server`: Collect metrics in my Kubernetes Cluster

`pod-identity-agent`: is a component in Amazon EKS that allows Pods to securely access AWS services without managing IAM roles manually via IRSA.

```
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"  
}

resource "aws_eks_addon" "core-dns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "metrics-server"
}

resource "aws_eks_addon" "pod-identity-agent" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "eks-pod-identity-agent"
}
```

#### Create Pod Identity Association

I need to give my Cluster Autoscaler permission to scale up and down my nodes on my behalf by using Pod Identity Association and associate with a Valid role . 

This way I don't need to create OID Connector provider 

```
resource "aws_eks_pod_identity_association" "cluster-autoscaler-pod-identity-association" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    namespace = "kube-system"
    service_account = "cluster-autoscaler"
    role_arn = data.aws_iam_role.cluster-autoscaler-role.arn
}
```

#### Create Access Entry 

Allow user to access EKS Cluster 

```
resource "aws_eks_access_entry" "eks-access-entry" {
    cluster_name = aws_eks_cluster.eks-cluster.name 
    principal_arn = "arn:aws:iam::660753258283:user/trinhnguyen"
    region = "us-west-1"
}
```

#### Create Access Policy Association 

When user can access EKS Cluster what can they do in my EKS Cluster 

```
resource "aws_eks_access_policy_association" "eks-access-policy-association" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    principal_arn = "arn:aws:iam::660753258283:user/trinhnguyen"
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

    access_scope {
        type = "cluster"
    }
}
```


