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
                    :rampervm => 256,
                    :drivertype => "vagrant",
                    :providertype => "virtualbox",           
                    :buildertype => "url",
                    :imagetype => "virtualbox",
                    :builderpath => "http://files.vagrantup.com/precise64.box",
                    :rebuild => false,
                    :privatenetwork => true
                }
                template("template.ke", ".hive/helloworld.ke", opts)
            end
        end
    end
end