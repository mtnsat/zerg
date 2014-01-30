require 'thor/group'
module Zerg
    module Generators
        class HiveGen < Thor::Group
            argument :create_hive, :type => :string, :required => false, :default => "true"
            argument :task_name, :type => :string, :required => false, :default => "helloworld"
            argument :naming_type, :type => :string, :required => false, :default => "sequence"
            argument :naming_prefix, :type => :string, :required => false, :default => "zergling"
            argument :instances, :type => :numeric, :required => false, :default => 1
            argument :driver, :type => :string, :required => false, :default => "vagrant"
            argument :type, :type => :string, :required => false, :default => "virtualbox"
            argument :rebuild, :type => :string, :required => false, :default => "false"
            include Thor::Actions

            def self.source_root
                File.join(File.dirname(__FILE__), "task")
            end

            def create_hive
                if @create_hive == "true"
                    empty_directory "hive"
                end
            end

            def copy_sample_task
                template("template.ke", "hive/#{task_name}.ke")
            end
        end
    end
end