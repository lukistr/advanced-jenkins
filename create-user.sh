#!/bin/bash

echo "* Create user jenkins ..."
sudo cat /etc/passwd | grep "jenkins" || sudo adduser jenkins

echo "* Change jenkins bash and set password ..."
sudo usermod -s /bin/bash jenkins
echo -e "jenkins\njenkins" | sudo passwd jenkins

echo "* Remove sudo password for jenkins ..."
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee >> /etc/sudoers