require 'awesome_print'
require 'fileutils'
require 'erb'
require 'rbconfig'

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

        def process(taskname, task, debug)
            puts ("Will perform task #{taskname} with contents:\n #{task.ai}")

            # render driver template
            renderer = DriverRenderer.new(
                task["vm"], 
                taskname, 
                task["instances"], 
                task["synced_folders"], 
                task["tasks"])
            
            renderer.render

            # do we need additional plugins?
            task["tasks"].each { |task|
                if task["type"] == "chef_client" || task["type"] == "chef_solo"
                    omnibus_pid = Process.spawn("vagrant plugin list | grep vagrant-omnibus")
                    Process.wait(omnibus_pid)

                    if $?.exitstatus != 0
                        omnibus_pid = Process.spawn("vagrant plugin install vagrant-omnibus")
                        Process.wait(aws_pid)
                        abort("ERROR: vagrant-omnibus installation failed!") unless $?.exitstatus == 0
                    end
                    break;
                end
            }

            run(taskname, task["vm"]["driver"]["providertype"], task["instances"], debug)
        end

        def cleanup(taskname, task, debug)
            abort("ERROR: Vagrant not installed!") unless which("vagrant") != nil
            puts ("Will cleanup task #{taskname}...")

            # TODO: generalize for multiple drivers
            # render driver template
            renderer = DriverRenderer.new(
                task["vm"], 
                taskname, 
                task["instances"],
                task["synced_folders"],  
                task["tasks"])        
            renderer.render

            # run vagrant cleanup
            debug_string = (debug == true) ? " --debug" : ""
            
            for index in 0..task["instances"] - 1
                cleanup_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant destroy zergling_#{index} --force#{debug_string}")
                Process.wait(cleanup_pid)
                abort("ERROR: vagrant failed!") unless $?.exitstatus == 0
            end

            cleanup_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                },
                "vagrant box remove zergling_#{taskname}_#{task["vm"]["driver"]["providertype"]}#{debug_string} #{task["vm"]["driver"]["providertype"]}")
            Process.wait(cleanup_pid)
        end

        def run(taskname, provider, instances, debug)
            # TODO: generalize to multiple drivers
            abort("ERROR: Vagrant not installed!") unless which("vagrant") != nil

            debug_string = (debug == true) ? " --debug" : ""
            # check plugin if correct plugin is present for aws
            if provider == "aws"
                aws_pid = Process.spawn("vagrant plugin list | grep vagrant-aws")
                Process.wait(aws_pid)

                if $?.exitstatus != 0
                    aws_pid = Process.spawn("vagrant plugin install vagrant-aws")
                    Process.wait(aws_pid)
                    abort("ERROR: vagrant-aws installation failed!") unless $?.exitstatus == 0
                end
            elsif provider == "libvirt"
                abort("ERROR: libvirt is only supported on a linux host!") unless /linux|arch/i === RbConfig::CONFIG['host_os']
                
                libvirt_pid = Process.spawn("vagrant plugin list | grep vagrant-libvirt")
                Process.wait(libvirt_pid)

                if $?.exitstatus != 0
                    libvirt_pid = Process.spawn("vagrant plugin install vagrant-libvirt")
                    Process.wait(libvirt_pid)
                    abort("ERROR: vagrant-libvirt installation failed! Refer to https://github.com/pradels/vagrant-libvirt to install missing dependencies, if any.") unless $?.exitstatus == 0
                end
            end
                

            # bring up all of the VMs first.
            puts("Starting vagrant in #{File.join("#{Dir.pwd}", ".hive", "driver", taskname)}")
            for index in 0..instances - 1
                create_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant up zergling_#{index} --no-provision --provider=#{provider}#{debug_string}")
                Process.wait(create_pid)
                
                if $?.exitstatus != 0
                    puts "ERROR: vagrant failed while creating one of the VMs. Will clean task #{taskname}:"
                    self.class.clean(taskname, debug)
                    abort("ERROR: vagrant failed!")
                end
            end

            puts("Running tasks in vagrant virtual machines...")
            # and provision them all at once (sort of)
            provisioners = Array.new
            provision_pid = nil
            for index in 0..instances - 1
                provision_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{Dir.pwd}", ".hive", "driver", taskname)
                    },
                    "vagrant provision zergling_#{index}#{debug_string}")
                provisioners.push({:name => "zergling_#{index}", :pid => provision_pid})
            end

            # wait for everything to finish...
            errors = Array.new
            lock = Mutex.new
            provisioners.each { |provisioner| 
                Thread.new { 
                    Process.wait(provisioner[:pid]); 
                    lock.synchronize do
                        errors.push(provisioner[:name]) unless $?.exitstatus == 0    
                    end
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
                    "vagrant halt zergling_#{index}#{debug_string}")
                Process.wait(halt_pid)
                abort("ERROR: vagrant halt failed on machine zergling_#{index}!") unless $?.exitstatus == 0
            end

            abort("ERROR: Finished with errors in: #{errors.to_s}") unless errors.length == 0
            puts("SUCCESS!")
        end

        def self.rush(task, debug)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # grab the current task hash and parse it out
            runner = Runner.new
            runner.process(task, Zerg::Hive.instance.hive[task], debug);
        end

        def self.clean(task, debug)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            runner = Runner.new
            runner.cleanup(task, Zerg::Hive.instance.hive[task], debug);
            puts("SUCCESS!")
        end
    end
end