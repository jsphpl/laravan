# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box_check_update = false
  config.ssh.insert_key = false

  config.vm.box = "bento/ubuntu-16.04"

  config.vm.network "private_network", ip: "192.168.0.42"
  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.vm.synced_folder ".", "/vagrant" #, disabled: true
  # config.vm.synced_folder "/var/www/domains", "/var/www/domains", type: "nfs", :mount_option => ['actimeo=2']

  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

end