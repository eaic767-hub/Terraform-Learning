resource "aws_instance" "nginx-server" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  # Instalación y configuración automática para UBUNTU
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              echo "<h1>¡Hola desde mi servidor Nginx desplegado con Terraform!</h1>" > /var/www/html/index.html
              systemctl enable --now nginx
              EOF

  user_data_replace_on_change = true
  key_name                    = aws_key_pair.nginx-server-ssh.key_name
  vpc_security_group_ids      = [aws_security_group.nginx-server-sg.id]

  tags = {
    Name = "Servidor-Prueba"
  }
}

resource "aws_key_pair" "nginx-server-ssh" {
  key_name   = "nginx-server-ssh"
  public_key = file("nginx-server.key.pub")
}

resource "aws_security_group" "nginx-server-sg" {
  name        = "nginx-server-sg"
  description = "security grup allowing SSH and HTTPS access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Muestra la URL directamente en tu terminal local al terminar
output "url_servidor" {
  value       = "http://${aws_instance.nginx-server.public_ip}"
  description = "Acceso directo a la página web"
}