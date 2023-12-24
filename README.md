## Steps

1) Create Architectural Diagram
2) Create app reg  
    1. ensure permisisons over resources is given 
    2. authentication via ADO service account mapped to app reg
3) Create storage account for state file

Terraform
1) main.tf
    include backend storage
2) networking.tf
    vcp
    subnet(s)
    securuty groups
3) instances.tf
    create ec2 key pair in aws
    web instances
    use datasource image 
4) variables

ADO
1) Setup service account in ADO
    a) use access key
2) Create build pipeline folders
    a) use ADO repo for deployments so set this as the origin
    b) create build pipeline (ensure this is in the folder)
        1. correct pipeline trigger
        2. TestAgentPool
        3. copy files
        4. publish artifact
3) Create release pipeline
    1. states file config
  
GIT
 - create a new branch 
    git checkout -b <branch-name>

 - check working branch 
    git branch

 -    


# scale set nic 
## First Option - Static Network Interface Definition:

network_interface {
  name    = "primary-nic"
  primary = true

  ip_configuration {
    name      = "internal"
    primary   = true
    subnet_id = element(var.private_app_subnets, count.index % length(var.private_app_subnets))
  }
}

This approach is suitable if you have a fixed number of subnets and you want to distribute the VM instances of the scale set across these subnets evenly. For example, if you have 2 subnets and 4 instances, each subnet will get 2 instances. The expression element(var.private_app_subnets, count.index % length(var.private_app_subnets)) picks a subnet from the list for each VM instance based on the count.index.

## Second Option - Dynamic Network Interface Definition:

dynamic "network_interface" {
  for_each = var.private_web_subnets

  content {
    name    = "primary-nic-${network_interface.key}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.private_web_subnets[network_interface.key]
    }
  }
}

This approach is useful when you want to create a network interface for each subnet defined in var.private_web_subnets. It's typically used when you have a scale set with multiple network interfaces, and each network interface is connected to a different subnet.

E:\Study\DevOps\Azure_DevOps_Courses\TERRAFORM\AZURE\Advanced Terraform with Azure\04 Working with VMs\006 Configure a VM Scale Set.mp4


Project Structure
-----------------

Explain the structure of your project directory and key files.

project-root/
│
├── modules/                  # Terraform modules (if any)
│
├── scripts/                  # Helper scripts (if any)
│
├── templates/                # Resource templates (if any)
│
├── main.tf                   # Main Terraform configuration
│
├── variables.tf              # Variable declarations
│
├── outputs.tf                # Output declarations
│
└── README.md                 # Project documentation
