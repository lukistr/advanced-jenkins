#!/bin/bash

echo "* Add repository about jenkins ..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

echo "* Read jenkins web admin password ..."
sudo cat /var/lib/jenkins/secrets/initialAdminPassword | sudo tee /vagrant/jenkins.txt

echo "* Change jenkins bash and set password ..."
sudo usermod -s /bin/bash jenkins
echo -e "jenkins\njenkins" | sudo passwd jenkins

echo "* Remove sudo password for jenkins ..."
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee >> /etc/sudoers

sudo su - jenkins

sudo mkdir /var/lib/jenkins/init.groovy.d
sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d/

echo "* Navigate to Jenkins installation directory and download jenkins-cli.jar ..."
cd /var/lib/jenkins
curl -O http://192.168.11.101:8080/jnlpJars/jenkins-cli.jar
sudo curl -L https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.11/jenkins-plugin-manager-2.12.11.jar \
-o /var/lib/jenkins/jenkins-plugin-manager.jar

echo "* Wait 30 sec for Jenkins to start up ..."
sleep 30s

INITIAL_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "* Create unlock.groovy file ..."
cat <<EOF > init.groovy.d/unlock.groovy
import jenkins.model.*
import hudson.security.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("jenkins", "jenkins")
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d/

echo "* Unlock Jenkins ..."
java -jar jenkins-cli.jar -auth admin:$INITIAL_ADMIN_PASSWORD -s http://localhost:8080 groovy = < init.groovy.d/unlock.groovy

echo "* Restart the service jenkins ..."
sudo systemctl restart jenkins

# Wait for Jenkins server to start
until curl --silent --fail http://192.168.11.101:8080/ >/dev/null; do
    echo "Waiting for Jenkins server to start..."
    sleep 10
done

echo "Jenkins server is now running!"

echo "* Install sugested plugins for jenkins ..."
sudo cp /vagrant/plugins.txt /usr/share/java/
java -jar /var/lib/jenkins/jenkins-plugin-manager.jar --plugin-file /usr/share/java/plugins.txt -d /var/lib/jenkins/plugins --verbose

echo "* Restart the service jenkins ..."
sudo systemctl restart jenkins

echo "* Copy jenkins settings ..."
rm /var/lib/jenkins/credentials.xml
cp /vagrant/jenkins/credentials.xml /var/lib/jenkins/
cp -r /vagrant/nodes/docker/ /var/lib/jenkins/nodes

sudo chown -R jenkins:jenkins /var/lib/jenkins

echo "* Restart the service jenkins ..."
sudo systemctl restart jenkins