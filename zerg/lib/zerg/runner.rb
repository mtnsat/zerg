require 'awesome_print'
require 'fileutils'
require 'erb'

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

        def process(taskname, task)
            puts ("Will perform task #{taskname} with contents:\n #{task.ai}")

            # TODO: render builder template and run it if required

            # render driver template
            renderer = DriverRenderer.new(task["vm"]["driver"], "hrbghrlghrl", taskname)
            render.render
        end


        def self.rush(task)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # grab the current task hash and parse it out
            runner = Runner.new
            runner.process(task, Zerg::Hive.instance.hive[task]);
        end
    end
end