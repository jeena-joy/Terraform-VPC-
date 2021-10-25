###################################################################
# Fetching Availability Zones
###################################################################


data "aws_availability_zones" "az" {
  state = "available"
}

###################################################################
# Vpc Creation
###################################################################
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

###################################################################
# Attaching Internet GateWay
###################################################################

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

###################################################################
# Creating Public Subnet1
###################################################################

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


###################################################################
# Creating Public Subnet2
###################################################################

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


###################################################################
# Creating Public Subnet3
###################################################################

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


###################################################################
# Creating Private Subnet1
###################################################################

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

###################################################################
# Creating Private Subnet2
###################################################################

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

###################################################################
# Creating Private Subnet3
###################################################################

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

#######################################################################
# Creating KeyPair
#######################################################################

resource "aws_key_pair" "mykey" {
    
  key_name   = "-key-name-"
  public_key = "-public-key-"
  tags       = { 
      Name = "terraform"
  }
}



#######################################################################
# SecurityGroup Creation
#######################################################################

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
