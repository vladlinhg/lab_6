# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
    sources = [
    "source.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo Creating necessary directories...",
      "sudo mkdir -p /var/www/html",              # Ensure the web directory exists
      "sudo mkdir -p /etc/nginx/sites-available", # Ensure Nginx config directory exists
      "sudo mkdir -p /etc/nginx/sites-enabled",   # Ensure Nginx sites-enabled directory

      "echo Setting permissions...",
      "sudo chown -R ubuntu:ubuntu /var/www/html",    # Set ownership to the 'ubuntu' user
      "sudo chmod -R 755 /var/www/html",              # Ensure readable & executable permissions
      "sudo chown -R root:root /etc/nginx",           # Secure Nginx config directory
      "sudo chmod -R 644 /etc/nginx/sites-available", # Readable by all, writable by root only
      "sudo chmod -R 644 /etc/nginx/sites-enabled",
      "sudo chmod 777 /etc/nginx/"
    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source      = "files/index.html"
    destination = "/var/www/html/index.html"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source      = "files/nginx.conf"    # Local nginx.conf file
    destination = "/etc/nginx/nginx.conf"  # Target location on the AMI
  }

  provisioner "shell" {
    script = "scripts/install-nginx"
  }

  provisioner "shell" {
    script = "scripts/setup-nginx"
  }
}

