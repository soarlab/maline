# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=4', 'tcp', 'nolock']
    }
  end

  config.vm.box = "ubuntu/precise64" # Ubuntu 12.04 64-bit

  config.vm.provider :libvirt do |domain|
    domain.disk_bus = "virtio"
    domain.memory = 2048
  end
  
  config.vm.provider :virtualbox do |domain|
    domain.memory = 2048
  end

  config.vm.provision :shell, privileged: true, path: "env/vagrant/prepare-node.sh"

  $script_mnt = <<SCRIPT_MNT
    mkdir -p /mnt/storage/custom-android-sdk
    chown -R vagrant:vagrant /mnt/storage/custom-android-sdk
    mkdir -p /mnt/experiments
    mkdir -p /mnt/storage/sdk
    chown -R vagrant:vagrant /mnt/storage/sdk
SCRIPT_MNT

  config.vm.provision :shell, privileged: true, inline: $script_mnt
  config.vm.provision :shell, privileged: false, path: "env/vagrant/set_android_env.sh"
  config.vm.provision :shell, privileged: false, path: "env/emulab/prepare-storage.sh"

  $script_sdk = <<SCRIPT_SDK
    cd /tmp
    wget http://www.cs.utah.edu/formal_verification/downloads/custom-android-sdk.tar.xz
    tar xf custom-android-sdk.tar.xz -C /mnt/storage/
SCRIPT_SDK

  config.vm.provision :shell, privileged: false, inline: $script_sdk

  $script_build = <<SCRIPT_BUILD
    cd /vagrant
    make
SCRIPT_BUILD
  
  config.vm.provision :shell, privileged: false, inline: $script_build
end
