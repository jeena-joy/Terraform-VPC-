# Building an AWS VPC with Terraform

When we need to set up AWS Virtual Private Cloud (VPC), we could make it happen via the AWS Management Console but automating it is so much easy. Building AWS services via tools like Terraform is a more scalable and automated approach to cloud resource provisioning.
A VPC is a virtual private network which can be used to logically separate cloud resources. For example, we can separate cloud resources for development and production.

## Pre-requisites

Terraform installed on your system.
AWS Account (Create if you don’t have one).
'access_key' & 'secret_key' of an AWS IAM User.

## Building the Terraform Configuration for an AWS VPC

- Create a dedicated directory where you can create terraform configuration files.

```sh
mkdir vpc-project
cd vpc-project
```

## Below are the resources that we are going to create with Terraform:-

- VPC
- Subnet inside created VPC
- Internet gateway with VPC
- Route table inside VPC with a route that will help to access the internet
- Route table associated with our subnet.
- Security group inside VPC


## Create provider.tf to define the AWS provider.

```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

## Create variable file variable.tf

variable.tf is a Terraform variables file that contains all the variables that the configuration file references.

You can see variables references in the configuration file by:

```sh
var.region
var.access_key
var.secret_key
var.project
var.vpc_cidr
var.vpc_subnets
```

## Create a variables.tfvars file 
variables.tfvars file is for dynamic variables declared in the variables.tf file, such as your AWS credentials, region,etc.


## Create main.tf 
main.tf is responsible for creating VPC on to AWS with the dependent resources. This main.tf will read values of variables from variables.tf and variables.tfvars.



#### Fetching Availability Zones

```sh
data "aws_availability_zones" "az" {
  state = "available"
}
``` 
#### Vpc Creation

```sh
resource "aws_vpc" "vpc" {
    
  cidr_block            =  var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "${var.project}-vpc"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```
#### Attaching Internet GateWay

We have two types of subnets - public and private. The Public subnet is used to create resources which can access external networks and can be accessed from external networks i.e. the internet directly. To enable this, we need to create an Internet Gateway:

```sh
resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```
#### Creating Public Subnet1

The subnet is used to logically separate cloud resources but inside VPC. Modify the definition file to add subnets

```sh
resource "aws_subnet" "public1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```

#### Creating Public Subnet2

```sh
resource "aws_subnet" "public2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}

```
#### Creating Public Subnet3

```sh
resource "aws_subnet" "public3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
    
}
```
#### Creating Private Subnet1

```sh
resource "aws_subnet" "private1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,3)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-private1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```
#### Creating Private Subnet2

```sh
resource "aws_subnet" "private2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,4)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-private2"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```

#### Creating Private Subnet3

```sh
resource "aws_subnet" "private3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,5)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-private3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

```
#### Creating Elastic Ip for NatGateWay

```sh
resource "aws_eip" "eip" {
  vpc      = true
  tags = {
    Name = "${var.project}-eip"
    Project = var.project
  }
}
```
#### Nat GateWay Creation

The Private subnet is where we put cloud resources which cannot be accessed from the external network. However, these resources might need access to an external network (i.e. internet), for example to update the operating system, download files, etc. Therefore, the NAT Gateway is needed to route traffic to external network.

```sh
resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-nat"
    Project = var.project
  }
}
```

#### Route Table Public
```sh
resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "${var.project}-public-rtb"
    Project = var.project
  }
}
```

#### Route Table Private
```sh
resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }


  tags = {
    Name = "${var.project}-private-rtb"
    Project = var.project
  }
}
```

#### Route Table association public route table
```sh
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
```

#### Route Table association Private route table

```sh
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
```

#### SecurityGroup Creation

```sh
resource "aws_security_group" "webserver" {

  name        = "terraform-webserver"
  description = "allow 80 port"

  ingress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },

    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    }


  ]

  egress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "terraform-webserver"
  }
}
```

#### Terraform Validation
> This will check for any errors on the source code

```sh
terraform validate
```
#### Terraform Plan
> The terraform plan command provides a preview of the actions that Terraform will take in order to configure resources per the configuration file. 

```sh
terraform plan
```
#### Terraform apply
> This will execute the tf file we created

```sh
terraform apply
```

-----


