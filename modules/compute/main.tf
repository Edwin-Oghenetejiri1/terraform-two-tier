data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install nginx -y
    systemctl start nginx
    systemctl enable nginx
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>HUG Terraform Challenge</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
          background: #1a1a2e;
          color: white;
        }
        .container {
          text-align: center;
          padding: 40px;
          border: 2px solid #e94560;
          border-radius: 10px;
        }
        h1 { color: #e94560; font-size: 2.5rem; }
        h2 { color: #4ecca3; font-size: 1.5rem; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Oghenetejiri Edwin</h1>
        <h2>HUG Lagos/Ibadan Terraform Challenge</h2>
      </div>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name = "${var.env_prefix}-instance"
  }
}