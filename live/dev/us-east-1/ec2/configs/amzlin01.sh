#!/bin/bash
echo "--- Starting User Data Setup ---"

# 1. Update the OS
yum update -y

# 2. Install useful tools (Git, Docker, etc.)
yum install -y git htop nano

# 3. Example: Install Apache Web Server to test connectivity
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Terragrunt!</h1>" > /var/www/html/index.html

echo "--- Setup Complete ---"