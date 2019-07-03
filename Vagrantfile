# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT

#!/bin/bash
echo "Installing dependencies"

echo $SOMETHING
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /home/vagrant/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /home/vagrant/.bashrc

apt-get update -qq
apt-get install -y -qqq jq unzip

################## kubectl ##################
echo "Installing kubectl"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update -qqq
apt-get install -y -qqq kubectl
echo 'source <(kubectl completion bash)' >> ~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl

################## terraform ##################
echo "Installing terraform"
curl -sLO https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
unzip terraform_0.11.7_linux_amd64.zip
mv terraform /usr/local/bin/terraform

################# kops ####################
echo "Installing kops"
curl -sLO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
mv kops-linux-amd64 /usr/local/bin/kops
echo 'source <(kops completion bash)' >> ~/.bashrc
kops completion bash >/etc/bash_completion.d/kops

echo "Finished installing dependencies"
SCRIPT

BOX = "ubuntu/xenial64"

Vagrant.configure("2") do |config|
  config.vm.box = BOX
  config.vm.hostname = "infra"
  config.vm.network "public_network"
  
  config.vm.synced_folder ".", "/infra"
  
  config.vm.provision "shell", 
    inline: $script,
    env: {
      'SOMETHING' => 'hello',
      'AWS_ACCESS_KEY_ID' => ENV['AWS_ACCESS_KEY_ID'],
      'AWS_SECRET_ACCESS_KEY' => ENV['AWS_SECRET_ACCESS_KEY'],
      'K8S_CLUSTER_ADMIN_SSHPUB' => '/infra/sshpublickey/id_rsa.pub',
    }

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Infrastructure Box"
    vb.memory = "4096"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

end
