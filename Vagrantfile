# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant"
  config.vm.box="luki_strike/Ubuntu"
  config.vm.box_version = "1.0.0"
  config.vm.provision "shell", path: "update.sh"
  config.vm.provider :virtualbox do |v|
	v.memory = 2560
	v.cpus = 1
  end

  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.hostname = "jenkins.do1.lab"
    jenkins.vm.network "private_network", ip: "192.168.11.101"
    jenkins.vm.provision "shell", path: "jenkins.sh"
  end
  
  config.vm.define "docker" do |docker|
    docker.vm.hostname = "docker.do1.lab"
    docker.vm.network "private_network", ip: "192.168.11.102"
	docker.vm.provision "shell", path: "create-user.sh"
	docker.vm.provision "shell", path: "docker.sh"
	docker.vm.provision "shell", path: "gitea.sh"
  end
  
end