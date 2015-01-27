# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network "private_network", type: "dhcp"

  config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 2003, host: 2003, auto_correct: true
  config.vm.network "forwarded_port", guest: 2004, host: 2004, auto_correct: true
  config.vm.network "forwarded_port", guest: 7002, host: 7002, auto_correct: true

  # VirtualBox Provider Config
  config.vm.provider "virtualbox" do |v|
    v.memory = 512
    v.cpus = 1
  end

  # AWS Provider Config
  require 'yaml'
  aws_config = YAML.load(File.read("config/aws.yaml"))

  config.vm.provider :aws do |aws, override|
    aws_config.each do |k, v|
      aws.send("#{k}=", v)
    end
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "/Users/jbussdieker/.ssh/id_rsa"
    override.vm.box = "dummy"
  end

  # Puppet Provisioner Config
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path = "modules"
    puppet.manifest_file  = "site.pp"
    puppet.hiera_config_path = "hiera.yaml"
    puppet.options = "--show_diff"
  end

  # Individual Node Config
  Dir[File.join("hieradata/nodes", "*.yaml")].sort.each do |node_yaml|
    require 'yaml'
    node = YAML.load_file(node_yaml)
    name = File.basename(node_yaml).split(".").first

    config.vm.define name do |box|
      box.vm.hostname = name
      box.vm.provider :aws do |aws, override|
        aws.tags = {
          'Name' => name,
        }
        aws.user_data = <<EOS
#cloud-config
hostname: #{name}
manage_etc_hosts: localhost
packages:
- puppet
EOS
      end
    end
  end
end
