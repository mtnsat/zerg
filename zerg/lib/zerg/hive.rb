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

require 'json'
require 'awesome_print'
require 'json-schema'
require 'fileutils'
require 'singleton'
require 'highline/import'
require_relative 'erbalize'

module Zerg
    class Hive
        include Singleton
        attr_reader :hive, :load_path
        
        def loaded
            @loaded || false
        end

        def load
            if loaded
                return
            end

            @load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", ".hive") : File.join("#{ENV['HIVE_CWD']}", ".hive")
            abort("ERROR: '.hive' not found at #{@load_path}. Run 'zerg init', change HIVE_CWD or run zerg from a different path.") unless File.directory?(@load_path) 

            # load all .ke files into one big hash
            @hive = Hash.new
            Dir.glob(File.join("#{@load_path}", "*.ke")) do |ke_file|
                # do work on files ending in .rb in the desired directory
                begin 
                    ke_file_hash = JSON.parse( IO.read(ke_file) )
                    @hive[File.basename(ke_file, ".ke")] = ke_file_hash
                rescue JSON::ParserError
                    abort("ERROR: Could not parse #{ke_file}. Likely invalid JSON.")
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
            instance.load

            Dir.glob(File.join("#{instance.load_path}", "*.ke")) do |ke_file|
                begin 
                    ke_file_hash = JSON.parse( File.open(ke_file, 'r').read )

                    # verify against schema.
                    # first get the tasks schema piece from the driver
                    pmgr = ZergGemPlugin::Manager.instance
                    pmgr.load
                    abort("ERROR: 'drivertype' is missing from #{ke_file}") unless ke_file_hash["vm"]["driver"]["drivertype"] != nil
                    driver = pmgr.create("/driver/#{ke_file_hash["vm"]["driver"]["drivertype"]}")
                    driver_schema = driver.task_schema

                    schema_template = File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "data", "ke.schema"), 'r').read
                    sources = {
                        :driver_tasks_schema => driver_schema
                    }
                    full_schema = JSON.parse(Erbalize.erbalize_hash(schema_template, sources))

                    errors = JSON::Validator.fully_validate(full_schema, ke_file_hash, :errors_as_objects => true)
                    abort("ERROR: #{ke_file} failed validation. Errors: #{errors.ai}") unless errors.empty?
                rescue JSON::ParserError => err
                    abort("ERROR: Could not parse #{ke_file}. Likely invalid JSON.")
                rescue ZergGemPlugin::PluginNotLoaded
                    abort("ERROR: driver #{ke_file_hash["vm"]["driver"]["drivertype"]} not found. Did you install the plugin gem?")
                end
            end

            puts "SUCCESS!"
        end

        def self.import(file, force)
            instance.load
            abort("ERROR: '#{file}' not found!") unless File.exist?(file) 
            abort("ERROR: '#{File.basename(file)}' already exists in hive!") unless !File.exist?(File.join(instance.load_path, File.basename(file))) || force == true

            # check the file against schema.
            begin
                ke_file_hash = JSON.parse( IO.read(file) )
                errors = JSON::Validator.fully_validate(File.join("#{File.dirname(__FILE__)}", "../../data/ke.schema"), ke_file_hash, :errors_as_objects => true)
                abort("ERROR: #{file} failed validation. Errors: #{errors.ai}") unless errors.empty?

                FileUtils.cp(file, File.join(instance.load_path, File.basename(file)))
            rescue JSON::ParserError => err
                abort("ERROR: Could not parse #{file}. Likely invalid JSON.")
            end
            puts "SUCCESS!"
        end

        def self.remove(taskname, force)
            instance.load 
            abort("ERROR: '#{taskname}' not found!") unless File.exist?(File.join(instance.load_path, "#{taskname}.ke")) 

            # check the file against schema.
            taskfile = File.join(instance.load_path, "#{taskname}.ke")

            agreed = true
            if force != true
                agreed = agree("Remove task #{taskname}?")
            end

            abort("Cancelled!") unless agreed == true

            FileUtils.rm_rf(File.join(instance.load_path, "driver", taskname))
            FileUtils.rm(File.join(instance.load_path, "#{taskname}.ke"))

            puts "SUCCESS!"
        end
    end
end