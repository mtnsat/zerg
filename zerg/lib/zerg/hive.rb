require 'json'
require 'awesome_print'
require 'json-schema'
require 'fileutils'

module Zerg
    class Hive
        include Singleton
        attr_reader :hive
        
        def loaded
            @loaded || false
        end

        def load
            if loaded
                return
            end

            load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", "hive") : File.join("#{ENV['HIVE_CWD']}", "hive")
            if !File.directory?(load_path)
                abort("ERROR: 'hive' not found at #{load_path}. Run 'zerg init', change HIVE_CWD or run zerg from a different path.")
            end

            # load all .ke files into one big hash
            @hive = Hash.new
            Dir.glob(File.join("#{load_path}", "*.ke")) do |ke_file|
                # do work on files ending in .rb in the desired directory
                begin 
                    ke_file_hash = JSON.parse( IO.read(ke_file) )
                    @hive[File.basename(ke_file, ".ke")] = ke_file_hash
                rescue JSON::ParserError
                    abort("ERROR: Could not parse #{ke_file}. Run 'zerg hive verify' for more information.")
                end
            end

            @loaded = true
        end

        def self.list
            instance.load

            # iterate over hive configs and print out the names
            puts  "Current hive tasks are:"

            if instance.loaded == false
                puts "No hive loaded!"
                puts "FAILURE!"
                return
            end

            if instance.hive.empty?()
                puts "No tasks defined in hive."
                return
            end

            puts "#{instance.hive.length} tasks in current hive:"
            puts "#{instance.hive.keys.ai}"
        end

        def self.verify
            load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", "hive") : File.join("#{ENV['HIVE_CWD']}", "hive")
            if !File.directory?(load_path)
                abort("ERROR: 'hive' not found at #{load_path}. Run 'zerg init', change HIVE_CWD or run zerg from a different path.")
                return
            end

            Dir.glob(File.join("#{load_path}", "*.ke")) do |ke_file|
                begin 
                    ke_file_hash = JSON.parse( IO.read(ke_file) )

                    # verify against schema.
                    errors = JSON::Validator.fully_validate(File.join("#{File.dirname(__FILE__)}", "../../data/ke.schema"), ke_file_hash, :errors_as_objects => true)
                    unless errors.empty?
                        abort("ERROR: #{ke_file} failed validation. Errors: #{errors.ai}")
                    end
                rescue JSON::ParserError => err
                    abort("ERROR: Could not parse #{ke_file}. Error: #{err.ai}")
                end
            end

            puts "SUCCESS!"
        end
    end
end