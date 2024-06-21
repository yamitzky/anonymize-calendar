# Compute module main configuration

resource "aws_instance" "app_server" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id     = var.subnet_ids[count.index]

  tags = {
    Name        = "${var.environment}-app-server-${count.index + 1}"
    Environment = var.environment
  }
}
