# -*- mode: ruby -*-
# vi: set ft=ruby :

dir = File.dirname(File.expand_path(__FILE__))

require "yaml"
require "json"
require "#{dir}/vagrant/ruby/deep_merge"
require "#{dir}/vagrant/ruby/inventory_path"

# install required plugins if necessary
if ARGV[0] == 'up'
    # add required plugins here
    required_plugins = %w( vagrant-bindfs vagrant-google )
    missing_plugins = []
    required_plugins.each do |plugin|
        missing_plugins.push(plugin) unless Vagrant.has_plugin? plugin
    end

    if ! missing_plugins.empty?
        install_these = missing_plugins.join(' ')
        puts "Found missing plugins: #{install_these}.  Installing..."
        exec "vagrant plugin install #{install_these}; vagrant up"
    end
end

host_groups = {}
host_vars = {}

config = YAML.load_file "#{dir}/config.yml"

Vagrant.configure("2") do |vagrant|
    settings = config["machine"]
    # These values are the default options
    vagrant.bindfs.default_options = {
      force_user:   'vagrant',
      force_group:  'vagrant',
      perms:        'u=rwX:g=rD:o=rD',
    }

    #vagrant.vm.synced_folder "/Users/jbecker/projects/share", "/home/vagrant/nfs", type: :nfs
    #vagrant.bindfs.bind_folder "/vagrant-nfs", "/var/www/project", o:"nonempty", after: :provision

    if settings['provider'] == "google"
      vagrant.vm.provider :google do |google, override|
        google.google_project_id = "balmy-visitor-168516"
        google.google_client_email = "pimcore-deploy@balmy-visitor-168516.iam.gserviceaccount.com"
        google.google_json_key_location = "preis24-d701b65e6baf.json"

        override.ssh.username = settings['ssh']['user']
        override.ssh.private_key_path = settings['ssh']['key_file']

        google.zone = "europe-west3-a"

        google.zone_config "europe-west3-a" do |zone1a|
            zone1a.name = "pimcore-development-01"
            #zone1a.image = "debian-8-jessie-v20170918"
            zone1a.machine_type = "n1-standard-2"
            zone1a.zone = "europe-west3-a"
            zone1a.external_ip = "pimcore-development-01"
            zone1a.tags = ["http-server", "https-server"]
        end
      end
    end

    if settings['provider'] == "parallels"
        vagrant.vm.provider :parallels do |parallels|
          parallels.update_guest_tools = false
          parallels.memory = settings["memory"]
          parallels.cpus = settings["cpus"]
        end
    end

    if settings['provider']  == "virtualbox"
        vagrant.vm.provider :parallels do |parallels|
          parallels.memory = settings["memory"]
          parallels.cpus = settings["cpus"]
        end
    end

    # Setting up the guest system
    vagrant.vm.define settings["hostname"] do |machine|
      machine.vm.box = settings["box"]
      machine.vm.hostname = settings["hostname"]
      machine.vm.network "private_network", ip: settings["ip"]

      if settings.has_key?("forwarding")
        settings["forwarding"].each do |name, port|
          machine.vm.network "forwarded_port", guest: port["guest"], host: port["host"]
        end
      end
    end

    # Create host_vars
    if settings.has_key?("host_vars")
      hashes = {}

      settings["host_vars"].each do |section, values|
        hash = {
          "#{section}" => "'#{values.to_json}'"
        }
        hashes = hashes.deep_merge(hash)
      end

      host_vars[settings["hostname"]] = hashes
    end

    # Create host_groups for ansible inventory
    if settings.has_key?("host_groups")
      settings["host_groups"].each do |group|
        hash = {
          "#{group}" => [ settings["hostname"] ]
        }
        host_groups = host_groups.deep_merge(hash)
      end
    end

    vagrant.vm.provision :ansible do |ansible|
      ansible.limit = "all"
      ansible.playbook = "./ansible/#{config["playbook"]}"
      ansible.groups = host_groups
      ansible.host_vars = host_vars
      ansible.verbose = config["output"]
    end

    if config["run_local"]
      # Run local provisioning to populate inventory generated by vagrant
      vagrant.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "./ansible/#{config["playbook_local"]}"
        ansible.inventory_path = getInventoryPath("#{dir}/ansible.cfg")
        ansible.install = true
        ansible.limit = "localhost"
        ansible.verbose = config["output"]
      end
    end

end # vagranture