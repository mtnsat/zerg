require 'thor/group'
module Zerg
    module Generators
        class HiveGen < Thor::Group
            include Thor::Actions

            def self.source_root
                File.join(File.dirname(__FILE__), "task")
            end

            def create_hive
                load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", ".hive") : File.join("#{ENV['HIVE_CWD']}", ".hive")
                empty_directory "#{File.join(load_path, "driver")}"
                empty_directory "#{File.join(load_path, "basebox")}"
            end

            def copy_sample_task
                load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", ".hive") : File.join("#{ENV['HIVE_CWD']}", ".hive")
                opts = {
                    :instances => 3,
                    :drivertype => "vagrant",
                    :providertype => "virtualbox",
                    :baseboxpath => "http://files.vagrantup.com/precise64.box",
                    :privatenetwork => true
                }
                template("template.ke", "#{File.join(load_path, "helloworld.ke")}", opts)

                opts = {
                    :instances => 3,
                    :drivertype => "vagrant",
                    :providertype => "aws",
                    :baseboxpath => "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                    :privatenetwork => false
                }
                template("awstemplate.ke", "#{File.join(load_path, "helloaws.ke")}", opts)
            end
        end
    end
end