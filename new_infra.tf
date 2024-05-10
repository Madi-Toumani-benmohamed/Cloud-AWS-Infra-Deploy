
//------------------vpc

resource "aws_vpc" "vpc_admin" {
  cidr_block           = "10.0.0.0/16"


  tags = {
    Name = "vpc_admin"
  }
}

//------------------vpc

resource "aws_vpc" "vpc_client_1" {
  cidr_block           = "10.1.0.0/20"


  tags = {
    Name = "vpc_client_1"
  }
}
resource "aws_internet_gateway" "ig_bastion_1" {
    vpc_id = "${aws_vpc.vpc_admin.id}"

    tags = {
        "Name" = "ig_bastion_1"
    }    
}


resource "aws_route_table_association" "rtb_bastion_1" {
    subnet_id = "${aws_subnet.subnet_bastion_1.id}"
    route_table_id = "${aws_route_table.rtb_bastion_1.id}"


}


resource "aws_route" "bastion_to_client1" {
  route_table_id            = "${aws_route_table.rtb_bastion_1.id}"
  destination_cidr_block    = "${aws_vpc.vpc_client_1.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_peering_client_1.id}"
}


resource "aws_route_table" "rtb_bastion_1" {
    vpc_id = "${aws_vpc.vpc_admin.id}"
    

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ig_bastion_1.id}"
       
    } 

    tags = {
        "Name" = "rtb_bastion_1"
    } 
}



resource "aws_security_group" "sg_bastion_1" {
  vpc_id = "${aws_vpc.vpc_admin.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    "Name" = "sg_bastion_1"
    }

}

resource "aws_subnet" "subnet_bastion_1" {
    vpc_id = "${aws_vpc.vpc_admin.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true 

    tags = {
        "Name" = "10.0.2.0/24 - eu-east-1- bastion_1"
    }

}


 //---------ec2  creation 

 resource "aws_instance" "ec2_bastion_1" {
   ami           = "ami-058bd2d568351da34"
   instance_type = "t2.micro"
   key_name      =  "toto" 
   security_groups = ["${aws_security_group.sg_bastion_1.id}"]
   subnet_id     = "${aws_subnet.subnet_bastion_1.id}"
   user_data     = file("bastion.sh")
  
  

  # root disk
  root_block_device {
    volume_size           = 20
    volume_type           = "standard"
    delete_on_termination = true
    encrypted             = true
  }  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "standard"
    encrypted             = true
    delete_on_termination = true
  }

  
  
  tags = {
    Name = "ec2_bastion_1"
  }

 }

resource "aws_security_group" "sg_serveur_web_1" {
  vpc_id = "${aws_vpc.vpc_client_1.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["10.0.2.0/24"]
    description = "bastion acess"
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

      ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    "Name" = "sg_serveur_web_1"
    }

}

resource "aws_subnet" "subnet_serveur_web_1" {
    vpc_id = "${aws_vpc.vpc_client_1.id}"
    cidr_block = "10.1.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = false 

    tags = {
        "Name" = "10.1.0.0/24 - eu-east-1- serveur_web_1"
    }

}


 //---------ec2  creation 

 resource "aws_instance" "ec2_serveur_web_1" {
   ami           = "ami-058bd2d568351da34"
   instance_type = "t2.micro"
   key_name      =  "toto" 
   security_groups = ["${aws_security_group.sg_serveur_web_1.id}"]
   subnet_id     = "${aws_subnet.subnet_serveur_web_1.id}"
   user_data     = file("serveur_web.sh")
  
  

  # root disk
  root_block_device {
    volume_size           = 20
    volume_type           = "standard"
    delete_on_termination = true
    encrypted             = true
  }  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "standard"
    encrypted             = true
    delete_on_termination = true
  }

  
  
  tags = {
    Name = "ec2_serveur_web_1"
  }

 }

# ----------- Peering section 
resource "aws_vpc_peering_connection" "peering_peering_client_1" {
  vpc_id        = "${aws_vpc.vpc_admin.id}"
  peer_vpc_id   = "${aws_vpc.vpc_client_1.id}"
  peer_region   = "us-east-1"
}

data "aws_caller_identity" "peer_peering_client_1" {
  provider = aws.peer
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peering_peering_client_1" {
  provider                  = aws.peer
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_peering_client_1.id}"
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}


//------routage

resource "aws_route_table" "rtb_peering_client_1" {
  vpc_id = "${aws_vpc.vpc_client_1.id}"

  tags = {

    "Name" = "rtb_peering_client_1"
  }
}




resource "aws_route" "peering_route_peering_client_1" {
  route_table_id         = "${aws_route_table.rtb_peering_client_1.id}"
  destination_cidr_block = "10.0.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_peering_client_1.id}"

}


resource "aws_route_table_association" "rtb_peering_association" {
    subnet_id = "${aws_subnet.subnet_serveur_web_1.id}"
    route_table_id = "${aws_route_table.rtb_peering_client_1.id}"
}


output "public_ip_bastion_1" {
  value = aws_instance.ec2_bastion_1.public_ip
}


output "private_ip_serveur_web_1" {
  value = aws_instance.ec2_serveur_web_1.private_ip
}

/*
output "private_ip_serveur_web_2" {
  value = aws_instance.ec2_serveur_web_2.private_ip
}
*/