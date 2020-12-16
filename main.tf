resource aws_instance ec2 {
  ami = "ami-04d29b6f966df1537"
  instance_type = var.type
  tags  = {
    creator = "test"
  }
}

