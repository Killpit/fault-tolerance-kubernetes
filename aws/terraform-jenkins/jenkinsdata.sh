#!/bin/bash

# Update package index
sudo apt-get update -y

# Set the hostname
sudo hostnamectl set-hostname jenkins-server

# Install Git
sudo apt-get install git -y

# Install OpenJDK 17
sudo apt-get install openjdk-17-jdk -y

# Add Jenkins key and repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package index after adding Jenkins repo
sudo apt-get update -y

# Install Jenkins
sudo apt-get install jenkins -y

# Start and enable Jenkins service
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add Docker's official GPG key and repository
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt-get update -y

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add user to the Docker group
sudo usermod -aG docker $(whoami)

# Optional: newgrp will not persist after the script execution
# newgrp docker

# Change permissions on Docker socket (not recommended for production)
sudo chmod 777 /var/run/docker.sock

usermod -a -G docker ec2-user
usermod -a -G docker jenkins

# configure docker as cloud agent for jenkins
cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
sed -i 's/^ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/127.0.0.1:2375 -H unix:\/\/\/var\/run\/docker.sock/g' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker
systemctl restart jenkins