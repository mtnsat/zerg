require 'awesome_print'
require 'fileutils'
require 'erb'
require 'ostruct'

module Zerg
    class DriverRenderer
        class Erbalize < OpenStruct
            def self.erbalize_hash(template, sources)
                Erbalize.new(sources).render(template)
            end

            def render(template)
                ERB.new(template).result(binding)
            end
        end

        # generate a virtualbox - compatible MAC address
        def generateMACAddress()
            firstChar = (0..255).map(&:chr).select{|x| x =~ /[0-9A-Fa-f]/}.sample(1).join
            secondChar = (0..255).map(&:chr).select{|x| x =~ /[02468ACEace]/}.sample(1).join
            restOfChars = (0..255).map(&:chr).select{|x| x =~ /[0-9A-Fa-f]/}.sample(10).join
            return "#{firstChar}#{secondChar}#{restOfChars}"
        end

        def initialize( task, basebox_path, name )
            @task = task
            @boxpath = basebox_path
            @name = name
        end

        def render
            puts ("Rendering driver templates...")

            # TODO: generalize this processing better
            abort("ERROR: Driver type '#{@task["vm"]["driver"]["drivertype"]} is not supported.") unless (@task["vm"]["driver"]["drivertype"] == "vagrant")

            # load the template files
            main_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@task["vm"]["driver"]["drivertype"]}", "main.template"), 'r').read

            # load the provider top level template
            provider_parent_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@task["vm"]["driver"]["drivertype"]}", "provider.template"), 'r').read

            # load the provider specifics template
            abort("ERROR: Provider type '#{@task["vm"]["driver"]["providertype"]} is not supported.") unless File.exist?(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@task["vm"]["driver"]["drivertype"]}", "#{@task["vm"]["driver"]["providertype"]}.template"))
            provider_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@task["vm"]["driver"]["drivertype"]}", "#{@task["vm"]["driver"]["providertype"]}.template"), 'r').read

            # load the machine details template
            machine_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@task["vm"]["driver"]["drivertype"]}", "machine.template"), 'r').read

            # render templates....
            # render provider details to string
            provider_string = Erbalize.erbalize_hash(provider_template, { :ram_per_vm => @task["vm"]["ram_per_vm"] })

            # render provider parent
            sources =  {
                :provider => @task["vm"]["driver"]["providertype"],
                :provider_specifics => provider_string
            }
            provider_parent_string = Erbalize.erbalize_hash(provider_parent_template, sources)

            # render machine template
            all_macs = Array.new
            all_machines = ""
            for index in 0..@task["instances"]
                # nic bridging? 
                do_bridging = @task["vm"]["driver"].has_key?("bridge_nic")

                # mac address to use?
                new_mac = ""
                begin
                    new_mac = generateMACAddress()
                end while all_vagrant_boxes.include? new_mac

                # last ip octet offset for host only networking
                ip_octet_offest = index

                # tasks array rendered to ruby string
                tasks_array = @task["tasks"].to_s

                sources = {
                    :machine_name => "zergling_#{index}",
                    :do_bridging => do_bridging,
                    :bridged_eth_description => @task["vm"]["driver"].has_key?("bridge_nic") ? @task["vm"]["driver"]["bridge_nic"] : nil,
                    :octet_offset => ip_octet_offest,
                    :tasks_array => tasks_array
                }.delete_if { |k, v| v.empty? }

                machine_section = Erbalize.erbalize_hash(machine_template, sources)
                all_machines += "\n#{machine_section}"
            end

            sources = {
                :provider_section => provider_parent_string,
                :basebox_path => @boxpath,
                :vm_defines => all_machines 
            }
            full_template = Erbalize.erbalize_hash(main_template, sources)

            # write the file
            FileUtils.mkdir_p(File.join("#{Dir.pwd}", ".hive", "driver", @name))
            File.open(File.join("#{Dir.pwd}", ".hive", "driver", @name, "Vagrantfile"), 'w') { |file| file.write(full_template) }
        end
    end
end