require 'awesome_print'
require 'json-schema'
require 'fileutils'

module Zerg
    class Runner

        # cross platform way of checking if command is available in PATH
        def which(cmd)
            exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
            ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
                exts.each { |ext|
                exe = File.join(path, "#{cmd}#{ext}")
                return exe if File.executable? exe
                }
            end
          return nil
        end

        def parse(taskname, task)
            puts ("Will perform task #{task.ai} with contents:\n #{task.ai}")
        end

        def self.rush(task)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # grab the current task hash and parse it out
            runner = Runner.new
            runner.parse(task, Zerg::Hive.instance.hive[task]);
        end
    end
end