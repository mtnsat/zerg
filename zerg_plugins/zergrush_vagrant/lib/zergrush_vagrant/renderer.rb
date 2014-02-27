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

require 'awesome_print'
require 'fileutils'
require 'securerandom'
require 'ipaddress'
require 'digest/sha1'
require 'ipaddress'
require_relative 'erbalize'

class Renderer

    def initialize(hive_location, task_name, task_hash)
        @vm = task_hash["vm"]
        @name = task_name
        @num_instances = task_hash["num_instances"]
        @vm_instances = task_hash["vm"]["instances"]
        @hive_location = hive_location
    end

    def render
        puts ("Rendering driver templates...")

        # load the template files
        main_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "main.template"), 'r').read

        # load the provider top level template
        provider_parent_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "provider.template"), 'r').read

        # load the machine details template
        machine_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "machine.template"), 'r').read


        # render templates....

        # all machines
        all_machines = ""

        # JSON - defined range of ip addresses in CIDR format
        ip_range = (@vm.has_key?("private_ip_range")) ? IPAddress(@vm["private_ip_range"]).hosts : nil
        if ip_range != nil
            abort("ERROR: ip range (#{@vm["private_ip_range"]}) does not have enough ip addresses for all instances.") unless ip_range.length > @num_instances
        end

        # last explicitly defined vm instance. 
        last_defined_vm = nil

        # last explicitly defined driver option set
        last_defined_driveroption = nil

        # render a machine section for each instance.
        # each machine gets an explicitly defined instance
        # if there is no explicitly defined instance - last known explicitly defined instance information is used.
        # For example: if num_instances = 3 and there are 2 vm instances defined, then machine_0 gets instance definition 0, machine_1 gets instance 
        # definition 1, machine_2 gets instance definition 2
        for index in 0..@num_instances - 1

            # grab last defined vm instance, or keep the current one
            last_defined_vm = (@vm_instances[index] == nil) ? last_defined_vm : @vm_instances[index]

            # grab last defined driver options set, or keep the current one
            last_defined_driveroption = (@vm["driver"]["driveroptions"][index] == nil) ? last_defined_driveroption : @vm["driver"]["driveroptions"][index]

            # provider type
            provider = last_defined_driveroption["providertype"]

            # unique name
            unique_name = "zergling-#{index}-#{Digest::SHA1.hexdigest("#{@name}#{provider}#{last_defined_vm["basebox"]}#{@hive_location}")}"

            # render provider details to string
            provider_specifics = ""

            if provider == "aws"
                # inject private ip for aws provider (if not specified explicitly and if ip range is provided)
                if last_defined_driveroption.has_key?("provider_options")
                    if last_defined_driveroption["provider_options"].has_key?("subnet_id")
                        if !last_defined_driveroption["provider_options"].has_key?("private_ip_address")
                            if ip_range != nil
                                provider_specifics += "\t\t\t#{provider}.private_ip_address = #{ip_range[index]}"
                            end
                        end
                    end
                end

                # inject name tag
                if last_defined_driveroption.has_key?("provider_options")
                    if last_defined_driveroption["provider_options"].has_key?("tags")
                        if !last_defined_driveroption["provider_options"]["tags"].has_key?("Name")
                            last_defined_driveroption["provider_options"]["tags"]["Name"] = unique_name
                        end
                    else
                        last_defined_driveroption["provider_options"]["tags"] = { "Name" => unique_name } 
                    end
                end

            end

            if last_defined_driveroption.has_key?("provider_options")
                provider_options = last_defined_driveroption["provider_options"]
                
                provider_options.each do |key, value|
                    if value.is_a?(String)
                        provider_specifics += "\t\t\t#{provider}.#{key} = \"#{value}\"\n"
                    elsif value.is_a?(Array)
                        provider_specifics += "\t\t\t#{provider}.#{key} = #{value.to_json}\n"
                    else
                        provider_specifics += "\t\t\t#{provider}.#{key} = #{value}\n" 
                    end
                end
            end

            if last_defined_driveroption.has_key?("raw_options")
                raw_provider_options = last_defined_driveroption["raw_options"]    
                raw_provider_options.each { |raw_option|
                    provider_specifics += "\t\t\t#{raw_option}\n"
                }
            end

            # render networks
            network_specifics = ""
            if last_defined_vm.has_key?("networks")
                last_defined_vm["networks"].each { |network|
                    network_specifics += "\t\tzergling_#{index}.vm.network \"#{network["type"]}\""
                    if network.has_key?("bridge")
                        network_specifics += ", bridge: \"#{network["bridge"]}\""
                    end
                    if network.has_key?("ip")
                        network_specifics += ", ip: \"#{network["ip"]}\""
                    elsif ip_range != nil && network["type"] != "public_network"
                        # first host IP is the host machine
                        network_specifics += ", ip: \"#{ip_range[index + 1]}\""
                    end                        

                    if network.has_key?("additional")
                        network["additional"].each do |key, value|
                            if value.is_a?(String)
                                network_specifics += ", #{key}: \"#{value}\""
                            else
                                network_specifics += ", #{key}: #{value}" 
                            end
                        end
                    end
                    network_specifics += "\n"
                }
            end

            # render sync folders
            folder_specifics = ""
            if last_defined_vm.has_key?("synced_folders")
                last_defined_vm["synced_folders"].each { |folder| 
                    folder_specifics += "\t\tzergling_#{index}.vm.synced_folder \"#{folder["host_path"]}\", \"#{folder["guest_path"]}\""
                    if folder.has_key?("additional")
                        folder["additional"].each do |key, value|
                            if value.is_a?(String)
                                folder_specifics += ", #{key}: \"#{value}\""
                            else
                                folder_specifics += ", #{key}: #{value}" 
                            end
                        end 
                    end
                    folder_specifics += "\n"
                }
            end

            # render forwarded ports
            port_specifics = ""
            if last_defined_vm.has_key?("forwarded_ports")
                last_defined_vm["forwarded_ports"].each { |port| 
                    port_specifics += "\t\tzergling_#{index}.vm.network \"forwarded_port\", guest: #{port["guest_port"]}, host: #{port["host_port"]}"
                    if port.has_key?("additional")
                        port["additional"].each { |option|
                            option.each do |key, value|
                                if value.is_a?(String)
                                    port_specifics += ", #{key}: \"#{value}\""
                                else
                                    port_specifics += ", #{key}: #{value}" 
                                end
                            end
                        } 
                    end
                    port_specifics += "\n"
                }
            end

            # render ssh settings
            ssh_specifics = ""
            if last_defined_vm.has_key?("ssh")
                if last_defined_vm["ssh"].has_key?("username")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.username = \"#{last_defined_vm["ssh"]["username"]}\"\n"
                end

                if last_defined_vm["ssh"].has_key?("host")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.host = \"#{last_defined_vm["ssh"]["host"]}\"\n"
                end

                if last_defined_vm["ssh"].has_key?("port")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.port = #{last_defined_vm["ssh"]["port"]}\n"
                end

                if last_defined_vm["ssh"].has_key?("guest_port")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.guest_port = #{last_defined_vm["ssh"]["guest_port"]}\n"
                end

                if last_defined_vm["ssh"].has_key?("private_key_path")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.private_key_path = \"#{last_defined_vm["ssh"]["private_key_path"]}\"\n"
                end

                if last_defined_vm["ssh"].has_key?("forward_agent")
                    ssh_specifics += "\t\tzergling_#{index}.ssh.forward_agent = #{last_defined_vm["ssh"]["forward_agent"]}\n"
                end
                     
                if last_defined_vm["ssh"].has_key?("additional")
                    last_defined_vm["ssh"]["additional"].each { |option|
                        option.each do |key, value|
                            if value.is_a?(String)
                                ssh_specifics += "\t\tzergling_#{index}.ssh.#{key} = \"#{value}\"\n"
                            else
                                ssh_specifics += "\t\tzergling_#{index}.ssh.#{key} = #{value}\n" 
                            end
                        end
                    } 
                end
            end

            # render tasks array
            # inject randomized node_name into chef_client tasks
            last_defined_vm["tasks"].each { |task| 
                if task["type"] == "chef_client"
                    task["node_name"] = unique_name
                end
            }

            # tasks array rendered to ruby string. double encoding to escape quotes and allow for variable expansion
            tasks_array = last_defined_vm["tasks"].to_json.to_json

            sources = {
                :machine_name => "zergling_#{index}",
                :node_name => unique_name,
                :basebox_path => last_defined_vm["basebox"],
                :box_name => Digest::SHA1.hexdigest("#{@name}#{provider}#{last_defined_vm["basebox"]}"),
                :provider => provider,
                :provider_specifics => provider_specifics,
                :networks_array => network_specifics,
                :sync_folders_array => folder_specifics,
                :ports_array => port_specifics,
                :ssh_specifics => ssh_specifics,
                :tasks_array => tasks_array
            }.delete_if { |k, v| v.nil? }

            machine_section = Erbalize.erbalize_hash(machine_template, sources)
            all_machines += "\n#{machine_section}"
        end

        sources = {
            :vm_defines => all_machines
        }
        full_template = Erbalize.erbalize_hash(main_template, sources)

        # write the file
        puts ("Writing #{File.join("#{@hive_location}", "driver", @vm["driver"]["drivertype"], @name, "Vagrantfile")}...")
        FileUtils.mkdir_p(File.join("#{@hive_location}", "driver", @vm["driver"]["drivertype"], @name))
        File.open(File.join("#{@hive_location}", "driver", @vm["driver"]["drivertype"], @name, "Vagrantfile"), 'w') { |file| file.write(full_template) }
    end
end
