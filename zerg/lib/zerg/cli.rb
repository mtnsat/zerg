require 'thor'
require 'zerg'
require 'zerg/generators/hivegen'

module Zerg
    class HiveCLI < Thor
        desc "verify", "verifies hive tasks without loading them"
        def verify
            puts Zerg::Hive.verify
        end

        desc "list", "lists hive tasks"
        def list
            puts Zerg::Hive.list
        end

        register(Zerg::Generators::HiveGen, "init", "init", "initializes new hive")
    end

    class CLI < Thor  
        desc "init", "initializes new hive"
        def init
            Zerg::Generators::HiveGen.start
        end
              
        desc "hive SUBCOMMAND", "manage hive - a collection of task descriptions"
        subcommand "hive", HiveCLI
    end
end