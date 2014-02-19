require 'zerg'
require 'renderer'

# give this class the name you want for your command zergrush_vagrant
class Vagrant < ZergGemPlugin::Plugin "/driver"
    def rush hive_location, task_name, task_hash, debug
        puts "rush!"
    end

    def clean hive_location, task_name, task_hash, debug
        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        renderer.render

        # run vagrant cleanup
        debug_string = (debug == true) ? " --debug" : ""
        
        for index in 0..task_hash["instances"] - 1
            cleanup_pid = Process.spawn(
                {
                    "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name),
                    "VAGRANT_DEFAULT_PROVIDER" => task_hash["vm"]["driver"]["providertype"]
                },
                "vagrant destroy zergling_#{index} --force#{debug_string}")
            Process.wait(cleanup_pid)
            abort("ERROR: vagrant failed!") unless $?.exitstatus == 0
        end

        cleanup_pid = Process.spawn(
            {
                "VAGRANT_CWD" => File.join("#{hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name)
            },
            "vagrant box remove zergling_#{task_name}_#{task_hash["vm"]["driver"]["providertype"]}#{debug_string} #{task_hash["vm"]["driver"]["providertype"]}")
        Process.wait(cleanup_pid)
    end

    def halt hive_location, task_name, task_hash, debug
        puts "halt!"
    end
end

