#!/bin/bash

echo "* Download Jenkins CLI ..."
curl -o /home/vagrant/jenkins-cli.jar http://192.168.11.101:8080/jnlpJars/jenkins-cli.jar
sudo chmod 0777 /home/vagrant/jenkins-cli.jar

sleep 60

echo '* Create Jenkins job ...'
java -jar /home/vagrant/jenkins-cli.jar -s http://192.168.11.101:8080/ -http -auth jenkins:jenkins create-job Gitea-web < /vagrant/Gitea-web.xml
java -jar /home/vagrant/jenkins-cli.jar -s http://192.168.11.101:8080/ -http -auth jenkins:jenkins create-job Gitea-SCM < /vagrant/Gitea-SCM.xml

echo '* Build job ...'
java -jar /home/vagrant/jenkins-cli.jar -s http://192.168.11.101:8080/ -http -auth jenkins:jenkins build Gitea-web -f -v
java -jar /home/vagrant/jenkins-cli.jar -s http://192.168.11.101:8080/ -http -auth jenkins:jenkins build Gitea-SCM -f -v