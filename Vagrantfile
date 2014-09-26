# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :ubuntu do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.provision :shell, :path => "vm/ubuntu.sh"
  end

  config.vm.define :centos do |config|
    config.vm.box = "chef/centos-6.5"
    config.vm.provision :shell, :path => "vm/centos.sh"
  end

  config.vm.define :debian do |config|
    config.vm.box = "chef/debian-7.4"
    config.vm.provision :shell, :path => "vm/debian.sh"
  end

  config.vm.define :opensuse do |config|
    config.vm.box = "chef/opensuse-13.1"
    config.vm.provision :shell, :path => "vm/opensuse.sh"
  end

  config.vm.define :fedora do |config|
    config.vm.box = "chef/fedora-20"
    config.vm.provision :shell, :path => "vm/fedora.sh"
  end
end
