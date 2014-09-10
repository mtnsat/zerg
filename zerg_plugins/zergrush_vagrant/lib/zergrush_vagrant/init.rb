#--

# Copyright 2014 by MTN Sattelite Communications
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#++

require 'zerg'
require 'rbconfig'
require_relative 'renderer'

# give this class the name you want for your command zergrush_vagrant
class Vagrant < ZergGemPlugin::Plugin "/driver"
    def rush hive_location, task_name, task_hash, debug
        check_dependencies
        puts ("Will perform task #{task_name} with contents:\n #{task_hash.ai}")

        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        renderer.render

        debug_string = (debug == true) ? " --debug" : ""                

        # last explicitly defined driver option set
        last_defined_driveroption = nil

        # bring up all of the VMs first.
        puts("Starting vagrant in #{File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name)}")
        for index in 0..task_hash["num_instances"] - 1

            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]

            create_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                    "VAGRANT_DEFAULT_PROVIDER" => last_defined_driveroption["providertype"]
                },
                "vagrant up zergling_#{index} --no-provision#{debug_string}")
            Process.wait(create_pid)
            
            if $?.exitstatus != 0
                puts "Vagrant failed while creating one of the VMs. Will clean task #{task_name}:"
                clean(hive_location, task_name, task_hash, debug)
                abort("ERROR: vagrant failed!")
            end
        end

        last_defined_driveroption = nil
        puts("Running tasks in vagrant virtual machines...")
        # and provision them all at once (sort of)
        provisioners = Array.new
        provision_pid = nil
        for index in 0..task_hash["num_instances"] - 1
            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]

            provision_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                    "VAGRANT_DEFAULT_PROVIDER" => last_defined_driveroption["providertype"]
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

        # halt only the machines that are not marked as "keepalive"
        last_defined_driveroption = nil
        last_defined_vm = nil

        halt_pid = nil
        keepalive_left = false
        for index in 0..task_hash["num_instances"] - 1

            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]
            
            # grab last defined vm instance, or keep the current one
            last_defined_vm = (task_hash["vm"]["instances"][index] == nil) ? last_defined_vm : task_hash["vm"]["instances"][index]
            
            if last_defined_vm["keepalive"] != true
                halt_pid = Process.spawn(
                    {
                        "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                        "VAGRANT_DEFAULT_PROVIDER" => last_defined_driveroption["providertype"]
                    },
                    "vagrant halt zergling_#{index}#{debug_string}")
                Process.wait(halt_pid)
                abort("ERROR: vagrant halt failed on machine zergling_#{index}!") unless $?.exitstatus == 0
            else
                keepalive_left = true
                puts "zergling_#{index} is marked as keepalive, skipping halt..."
            end
        end
        abort("ERROR: Finished with errors in: #{errors.to_s}") unless errors.length == 0
        puts "Some instances were left running." unless keepalive_left == false
    end

    def clean hive_location, task_name, task_hash, debug
        check_dependencies
        puts("Cleaning task #{task_name} ...")

        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        renderer.render

        # run vagrant cleanup
        debug_string = (debug == true) ? " --debug" : ""
        
        last_defined_driveroption = nil

        for index in 0..task_hash["num_instances"] - 1

            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]

            cleanup_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                    "VAGRANT_DEFAULT_PROVIDER" => last_defined_driveroption["providertype"]
                },
                "vagrant destroy zergling_#{index} --force#{debug_string}")
            Process.wait(cleanup_pid)
            abort("ERROR: vagrant failed!") unless $?.exitstatus == 0
        end

        last_defined_driveroption = nil
        
        # last explicitly defined vm instance. 
        last_defined_vm = nil

        for index in 0..task_hash["num_instances"] - 1
            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]

            # grab last defined vm instance, or keep the current one
            last_defined_vm = (task_hash["vm"]["instances"][index] == nil) ? last_defined_vm : task_hash["vm"]["instances"][index]
            
            boxname = Digest::SHA1.hexdigest "#{task_name}#{last_defined_driveroption["providertype"]}#{last_defined_vm["basebox"]}"
            cleanup_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name)
                },
                "vagrant box remove #{boxname} #{last_defined_driveroption["providertype"]}#{debug_string}")
            Process.wait(cleanup_pid)
        end
    end

    def halt hive_location, task_name, task_hash, debug
        check_dependencies
        puts("Halting all vagrant virtual machines for task #{task_name} ...")
        
        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        renderer.render

        debug_string = (debug == true) ? " --debug" : ""  

        # halt all machines
        halt_pid = nil

        last_defined_driveroption = nil

        for index in 0..task_hash["num_instances"] - 1

            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (task_hash["vm"]["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : task_hash["vm"]["driver"]["driveroptions"][index]
            
            halt_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                    "VAGRANT_DEFAULT_PROVIDER" => last_defined_driveroption["providertype"]
                },
                "vagrant halt zergling_#{index}#{debug_string}")
            Process.wait(halt_pid)
            abort("ERROR: vagrant halt failed on machine zergling_#{index}!") unless $?.exitstatus == 0
        end
    end

    def snapshot hive_location, task_name, task_hash, base
        abort("ERROR: Not implemented!")
    end

    def task_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "tasks_schema.template"), 'r').read
    end

    def option_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "option_schema.template"), 'r').read
    end

    def folder_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "folders_schema.template"), 'r').read
    end

    def port_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "ports_schema.template"), 'r').read
    end

    def ssh_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "ssh_schema.template"), 'r').read
    end

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

    def check_dependencies
        abort("ERROR: Vagrant not installed!") unless which("vagrant") != nil
        required_plugins = ["vagrant-aws", "vagrant-omnibus", "vagrant-berkshelf"]
        if /linux|arch/i === RbConfig::CONFIG['host_os']
            required_plugins.push("vagrant-libvirt")
        end

        required_plugins.each { |plugin|
            plugin_check_pid = Process.spawn("vagrant plugin list | grep #{plugin}")
            Process.wait(plugin_check_pid)

            if $?.exitstatus != 0
                puts "Installing #{plugin}"
                plugin_check_pid = Process.spawn("vagrant plugin install #{plugin}")
                Process.wait(plugin_check_pid)
                abort("ERROR: #{plugin} installation failed!") unless $?.exitstatus == 0
            end
        }
    end
end

