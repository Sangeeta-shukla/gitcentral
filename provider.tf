provider "aws" {
    region = "us-east-1"
}

######## VPC #######

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

############# internet gateway ###############

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

#####################subnet#############

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet"
  }
}


################ Route Table##############

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "rt"
  }
}


########### route#################

resource "aws_route" "route1" {
  route_table_id            = aws_route_table.rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.myigw.id
  depends_on                = [aws_route_table.rt]
}


############### security group #################


resource "aws_security_group" "sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "all traffic from VPC"
    from_port        = 0  # all ports
    to_port          = 0  # all ports
    protocol         = "-1"  # all traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    prefix_list_ids  = null
    security_groups  = null
    self             = null
    description      = "outbound rule"
    }

  tags = {
    Name = "sg"
  }
}

#################### route table association########################

resource "aws_route_table_association" "associationA" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "associationB" {
  gateway_id     = aws_internet_gateway.myigw.id
  route_table_id = aws_route_table.rt.id
}

#################### ec2##################

resource "aws_instance" "web" {
  ami           = "ami-061ac2e015473fbe2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id

  tags = {
    Name = "HelloWorld"
  }
}


│ Error: error creating Route in Route Table (rtb-02d71a9051aefa67d) with destination (10.0.0.0/16): RouteConflict: Route table has a conflicting association with the gateway igw-08f5117e09d1eba27
│       status code: 400, request id: cdc2d7aa-b1ee-4f14-985f-90aa86b0ca1a
│
│   with aws_route.route1,
│   on provider.tf line 48, in resource "aws_route" "route1":
│   48: resource "aws_route" "route1" {
│
