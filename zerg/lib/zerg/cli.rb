require 'thor'
require 'zerg'
require 'zerg/generators/hivegen'

module Zerg
    class HiveCLI < Thor
        
        # hack (https://github.com/erikhuda/thor/issues/261#issuecomment-16880836)
        # to get around thor showing klass name snake case in subcommand help (instead of subcommand name) 
        package_name "hive"
        def self.banner(command, namespace = nil, subcommand = false)
            "#{basename} #{@package_name} #{command.usage}"
        end

        desc "verify", "verifies hive tasks without loading them"
        def verify
            puts Zerg::Hive.verify
        end

        desc "list", "lists hive tasks"
        def list
            puts Zerg::Hive.list
        end

        desc "import [FILE] [--force]", "import a .ke file into the hive folder"
        option :force, :type => :boolean
        def import(file)
            puts Zerg::Hive.import(file, options[:force])
        end

        desc "remove [TASK] [--force]", "remove a task from hive"
        option :force, :type => :boolean
        def remove(file)
            puts Zerg::Hive.remove(file, options[:force])
        end
    end

    class CLI < Thor  
        def self.exit_on_failure?
            true
        end

        desc "init", "initializes new hive"
        def init
            puts Zerg::Generators::HiveGen.start
        end

        desc "rush [TASK] [--debug]", "runs a task from hive"
        option :debug, :type => :boolean
        def rush(task)
            puts Zerg::Runner.rush(task, options[:debug])
        end

        desc "clean [TASK] [--debug]", "cleans a task"
        option :debug, :type => :boolean
        def clean(task)
            puts Zerg::Runner.clean(task, options[:debug])
        end
          
        register(HiveCLI, 'hive', 'hive [COMMAND]', 'Manage hive - a collection of task descriptions.')
    end
end