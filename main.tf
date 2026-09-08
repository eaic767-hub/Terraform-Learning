resource "aws_instance" "nginx-server" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI en us-east-1
  instance_type = "t3.micro"

  ##instalación, habilitación e inicializacion de nginx
  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
    
  #linkeo el resource externo ssh
  key_name = aws_key_pair.nginx-server-ssh.key_name
  
  #linkeo el resource externo sg
  vpc_security_group_ids = [ aws_security_group.nginx-server-sg.id ]
  #Etiqueta del nombre del servidor       
  tags = {
    Name = "Servidor-Prueba"
  }
}
##recurso de la clave generada en git bash...
######SSH######
resource "aws_key_pair" "nginx-server-ssh" {
  key_name = "nginx-server-ssh"
  public_key = file("nginx-server.key.pub")
}
######SG#####
resource "aws_security_group" "nginx-server-sg" {
  name = "nginx-server-sg"
  description = "security grup allowing SSH and HTTPS access"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}
