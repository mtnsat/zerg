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

        def initialize( driver, basebox_path, name, ram, instances, tasks )
            @driver = driver
            @boxpath = basebox_path
            @name = name
            @ram = ram
            @instances = instances
            @tasks = tasks
        end

        def render
            puts ("Rendering driver templates...")

            # TODO: generalize this processing better
            abort("ERROR: Driver type '#{@driver["drivertype"]} is not supported.") unless (@driver["drivertype"] == "vagrant")

            # load the template files
            main_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "main.template"), 'r').read

            # load the provider top level template
            provider_parent_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "provider.template"), 'r').read

            # load the provider specifics template
            abort("ERROR: Provider type '#{@driver["providertype"]} is not supported.") unless File.exist?(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "#{@driver["providertype"]}.template"))
            provider_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "#{@driver["providertype"]}.template"), 'r').read

            # load the machine details template
            machine_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "machine.template"), 'r').read

            # load the bridge details template
            bridge_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@driver["drivertype"]}", "bridging.template"), 'r').read

            # render templates....
            # render provider details to string
            provider_string = Erbalize.erbalize_hash(provider_template, { :ram_per_vm => @ram })

            # render provider parent
            sources =  {
                :provider => @driver["providertype"],
                :provider_specifics => provider_string
            }
            provider_parent_string = Erbalize.erbalize_hash(provider_parent_template, sources)

            # render machine template
            all_macs = Array.new
            all_machines = ""
            for index in 0..@instances - 1

                # last ip octet offset for host only networking
                ip_octet_offset = index

                # tasks array rendered to ruby string
                tasks_array = @tasks.to_s

                # do we need the bridging template as well?
                bridge_section = nil
                if @driver.has_key?("bridge_nic")
                    # mac address to use?
                    new_mac = ""
                    begin
                        new_mac = generateMACAddress()
                    end while all_macs.include? new_mac

                    sources = {
                        :machine_mac => new_mac,
                        :bridged_eth_description => @driver["bridge_nic"]
                    }
                    bridge_section = Erbalize.erbalize_hash(bridge_template, sources)
                end

                sources = {
                    :machine_name => "zergling_#{index}",
                    :bridged_eth_description => @driver.has_key?("bridge_nic") ? @driver["bridge_nic"] : nil, 
                    :bridge_specifics => bridge_section,
                    :last_octet => ip_octet_offset + 4, # TODO: this is probably specific to virtualbox networking
                    :tasks_array => tasks_array
                }.delete_if { |k, v| v.nil? }

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
            puts ("Writing #{File.join("#{Dir.pwd}", ".hive", "driver", @name, "Vagrantfile")}...")
            FileUtils.mkdir_p(File.join("#{Dir.pwd}", ".hive", "driver", @name))
            File.open(File.join("#{Dir.pwd}", ".hive", "driver", @name, "Vagrantfile"), 'w') { |file| file.write(full_template) }
        end
    end
end