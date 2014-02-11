require 'awesome_print'
require 'fileutils'
require 'erb'
require 'ostruct'
require 'securerandom'

module Zerg
    class DriverRenderer
        class Erbalize < OpenStruct
            def self.erbalize_hash(template, sources)
                Erbalize.new(sources).render(template)
            end

            def render(template)
                ERB.new(template, nil, '-').result(binding)
            end
        end

        # generate a virtualbox - compatible MAC address
        def generateMACAddress()
            firstChar = (0..255).map(&:chr).select{|x| x =~ /[0-9A-Fa-f]/}.sample(1).join
            secondChar = (0..255).map(&:chr).select{|x| x =~ /[02468ACEace]/}.sample(1).join
            restOfChars = (0..255).map(&:chr).select{|x| x =~ /[0-9A-Fa-f]/}.sample(10).join
            return "#{firstChar}#{secondChar}#{restOfChars}"
        end

        def initialize(vm, name, instances, synced_folders, tasks )
            @vm = vm
            @name = name
            @instances = instances
            @tasks = tasks
            @synced_folders = synced_folders
        end

        def render
            puts ("Rendering driver templates...")

            # TODO: generalize this processing better
            abort("ERROR: Driver type '#{@vm["driver"]["drivertype"]} is not supported.") unless (@vm["driver"]["drivertype"] == "vagrant")

            # load the template files
            main_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@vm["driver"]["drivertype"]}", "main.template"), 'r').read

            # load the provider top level template
            provider_parent_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@vm["driver"]["drivertype"]}", "provider.template"), 'r').read

            # load the machine details template
            machine_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@vm["driver"]["drivertype"]}", "machine.template"), 'r').read

            # load the bridge details template
            bridge_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@vm["driver"]["drivertype"]}", "bridging.template"), 'r').read

            # load the host only network details template
            hostonly_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "driver", "#{@vm["driver"]["drivertype"]}", "hostonly.template"), 'r').read

            # render templates....
            # render provider details to string
            # 
            # render provider details into a string
            provider_details_array = @vm["driver"]["provider_options"]
            provider_details = ""
            for index in 0..provider_details_array.length - 1
                provider_details += "\t\t" + provider_details_array[index] + "\n"
            end

            # render provider parent
            sources =  {
                :provider => @vm["driver"]["providertype"],
                :provider_specifics => provider_details
            }
            provider_parent_string = Erbalize.erbalize_hash(provider_parent_template, sources)

            # render machine template
            all_macs = Array.new
            all_machines = ""
            for index in 0..@instances - 1

                # last ip octet offset for host only networking
                ip_octet_offset = index

                # inject randomized node_name into chef_client tasks
                @tasks.each { |task| 
                    if task["type"] == "chef_client"
                        task["node_name"] = "zergling_#{index}_#{SecureRandom.hex(20)}"
                    end
                }

                # tasks array rendered to ruby string. double encoding to escape quotes and allow for variable expansion
                tasks_array = @tasks.to_json.to_json

                # do we need the bridging template as well?
                bridge_section = nil
                if @vm.has_key?("bridge_description")
                    # mac address to use?
                    new_mac = ""
                    begin
                        new_mac = generateMACAddress()
                    end while all_macs.include? new_mac

                    sources = {
                        :machine_mac => new_mac,
                        :bridged_eth_description => @vm["bridge_description"]
                    }
                    bridge_section = Erbalize.erbalize_hash(bridge_template, sources)
                end

                # do we need the host only template as well?
                hostonly_section = nil
                if @vm["private_network"] == true
                    sources = {
                        :machine_name => "zergling_#{index}",
                        :last_octet => ip_octet_offset + 4, # TODO: this is probably specific to virtualbox networking
                    }
                    hostonly_section = Erbalize.erbalize_hash(hostonly_template, sources)
                end

                # blah
                folder_definitions = ""
                @synced_folders.each { |folder| 
                    other_options = ""
                    if folder.has_key?("options")
                        folder["options"].each { |option|
                            option.each do |key, value|
                                if value.is_a?(String)
                                    other_options += ", :#{key} => \"#{value}\""
                                else
                                    other_options += ", :#{key} => #{value}" 
                                end
                            end
                        } 
                    end

                    folder_definition = "zergling_#{index}.vm.synced_folder \"#{folder['host_path']}\", \"#{folder['guest_path']}\""
                    folder_definition = "#{folder_definition}#{other_options}" unless other_options.empty?()
                    folder_definitions += "\t\t#{folder_definition}\n"
                }

                sources = {
                    :machine_name => "zergling_#{index}",
                    :bridge_specifics => bridge_section,
                    :hostonly_specifics => hostonly_section,
                    :tasks_array => tasks_array,
                    :sync_folders_array => folder_definitions 
                }.delete_if { |k, v| v.nil? }

                machine_section = Erbalize.erbalize_hash(machine_template, sources)
                all_machines += "\n#{machine_section}"
            end

            sources = {
                :provider_section => provider_parent_string,
                :basebox_path => @vm["basebox"],
                :box_name => "zergling_#{@name}_#{@vm["driver"]["providertype"]}",
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