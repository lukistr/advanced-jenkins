#!/bin/bash

echo "* Add hosts ..."
echo "192.168.11.101 jenkins.do1.lab jenkins" >> /etc/hosts
echo "192.168.11.102 docker.do1.lab docker" >> /etc/hosts

echo "* Install Software ..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release tar bzip2 wget jq tree git vim fontconfig openjdk-17-jre

echo "* Open firewall ports ..."
sudo ufw allow 8080
sudo ufw allow 80
sudo ufw allow 3000
sudo ufw allow openssh
sudo ufw disable && sudo ufw --force enable