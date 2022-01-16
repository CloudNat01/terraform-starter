variable "awslocation" {
    type = map(string)
    default = {
      region = "us-west-2"
      az     = "us-west-2b"
    }
  
}

variable "awsprojectcontent" {
    type = map(string)
    default = {
      image-name = "ami-066333d9c572b0680"
      key-name  = "cloudnat-key"
      instance-type  = "t2.micro"
      server-name1   = "jenkins-server"
      sgrp-name = "allow_tcp_traffic"
      subnet-name  = "custom-subnet"
      vpc-name  = "custome-vpc"
    }
  
}

variable "openPortNum" {
  type = map(number)
  default = {
    JENKINS = 8080
    SSH    = 22
    HTTP   = 80
    HTTPS  = 443
    
  }
  
}