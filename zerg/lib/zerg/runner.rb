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
            renderer = DriverRenderer.new(
                task["vm"]["driver"], 
                task["vm"]["builder"]["builderpath"], # TODO: this should change based on what builder output is
                taskname, 
                task["ram_per_vm"], 
                task["instances"], 
                task["tasks"])
            
            renderer.render
            run(taskname, task["instances"])
        end

        def cleanup(taskname, instances)
            puts ("Will cleanup task #{taskname}...")

            # TODO: generalize for multiple drivers

            # run vagrant cleanup
            cleanup_pid = nil
            for index in 0..instances - 1
                cleanup_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant destroy zergling_#{index} --force")
                Process.wait(cleanup_pid)
                abort("ERROR: vagrant failed!") unless $?.exitstatus == 0
            end
        end

        def run(taskname, instances)
            # TODO: generalize to multiple drivers
            abort("ERROR: Vagrant not installed!") unless which("vagrant") != nil

            # bring up all of the VMs first.
            puts("Starting vagrant in #{File.join("#{Dir.pwd}", ".hive", "driver", taskname)}")
            create_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                },
                "vagrant up --no-provision"
            )
            Process.wait(create_pid)
            abort("ERROR: vagrant failed!") unless $?.exitstatus == 0

            puts("Running tasks in vagrant virtual machines...")
            # and provision them all at once (sort of)
            provisioners = Array.new
            provision_pid = nil
            for index in 0..instances - 1
                provision_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant provision zergling_#{index}")
                provisioners.push({:name => "zergling_#{index}", :pid => provision_pid})
            end

            # wait for everything to finish...
            provisioners.each { |provisioner| 
                Thread.new { 
                    Process.wait(provisioner[:pid]);     
                }.join 
            }

            puts("DONE! Halting all vagrant virtual machines...")
            # halt all machines
            halt_pid = nil
            for index in 0..instances - 1
                halt_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant halt zergling_#{index}")
                Process.wait(halt_pid)
                abort("ERROR: vagrant halt failed on machine zergling_#{index}!") unless $?.exitstatus == 0
            end

            puts("SUCCESS!")
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

        def self.clean(task)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # grab the current task hash and parse it out
            runner = Runner.new
            runner.cleanup(task, Zerg::Hive.instance.hive[task]["instances"]);
            puts("SUCCESS!")
        end
    end
end