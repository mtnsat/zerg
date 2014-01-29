require 'thor'
require 'zerg'

module Zerg
    class CLI < Thor        
        class HiveCLI < Thor
            desc "verify", "verifies hive tasks without loading them"
            def verify
                puts Zerg::Hive.verify(Dir.pwd)
            end

            desc "load", "loads all hive tasks"
            def load
                puts Zerg::Hive.load(Dir.pwd)
            end
        end

        desc "hive SUBCOMMAND", "manage hive - a collection of task descriptions"
        subcommand "hive", HiveCLI
    end
end