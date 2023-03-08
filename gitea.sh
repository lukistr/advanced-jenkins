#!/bin/bash

echo "* Start Gitea server ..."
docker compose -f /vagrant/docker-compose.yml up -d

# Wait for Gitea server to start
until curl --silent --fail http://192.168.11.102:3000/ >/dev/null; do
    echo "Waiting for Gitea server to start..."
    sleep 10
done

# Gitea server is ready
echo "Gitea server is now running!"

echo "* Create admin user ..."
docker container exec -u 1001 gitea gitea admin user create --username vagrant --password docker --email vagrant@do1.lab

echo "* Clone github repo ..."
git clone https://github.com/lukistr/appcourse.git /home/vagrant/gitea-bgapp

echo '* Import Docker compose file and Jenkinsfile into repository ...'
cp /vagrant/docker-deploy-compose.yaml /home/vagrant/gitea-bgapp
cp /vagrant/Jenkinsfile /home/vagrant/gitea-bgapp

echo "* Add repo to gitea ..."
cd /home/vagrant/gitea-bgapp && git add .

echo "* Commiting ..."
git commit -m "Build repo"

echo "* Push repo ..."
git push -o repo.private=false http://vagrant:docker@192.168.11.102:3000/vagrant/gitea-bgapp