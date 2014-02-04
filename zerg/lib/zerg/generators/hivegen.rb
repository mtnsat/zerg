require 'thor/group'
module Zerg
    module Generators
        class HiveGen < Thor::Group
            include Thor::Actions

            def self.source_root
                File.join(File.dirname(__FILE__), "task")
            end

            def create_hive
                empty_directory ".hive/builder"
                empty_directory ".hive/driver"
                empty_directory ".hive/basebox"
            end

            def copy_sample_task
                opts = {
                    :instances => 3,
                    :drivertype => "vagrant",
                    :providertype => "virtualbox",
                    :baseboxpath => "http://files.vagrantup.com/precise64.box",
                    :privatenetwork => true
                }
                template("template.ke", ".hive/helloworld.ke", opts)

                opts = {
                    :instances => 3,
                    :drivertype => "vagrant",
                    :providertype => "aws",
                    :baseboxpath => "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                    :privatenetwork => false
                }
                template("awstemplate.ke", ".hive/helloworld.ke", opts)
            end
        end
    end
end