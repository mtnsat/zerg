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
require 'fog'
require 'excon'
require 'rbconfig'
require 'awesome_print'
require 'securerandom'
require_relative 'renderer'

class CloudFormation < ZergGemPlugin::Plugin "/driver"
    def rush hive_location, task_name, task_hash, debug
        aws_key_id = task_hash["vm"]["driver"]["driveroptions"]["access_key_id"] 
        aws_secret = task_hash["vm"]["driver"]["driveroptions"]["secret_access_key"] 

        abort("AWS key id is not specified in task") unless aws_key_id != nil
        abort("AWS secret is not specified in task") unless aws_secret != nil
        puts ("Will perform task #{task_name} with contents:\n #{task_hash.ai}")

        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        template_body = renderer.render

        cf = CloudFormation.new(
            :aws_access_key_id => aws_key_id,
            :aws_secret_access_key => aws_secret
        )

        # create the cloudformation stack
        stack_name = "#{task_name}_#{SecureRandom.hex}"
        stack_info = cf.create_stack(stack_name, { :TemplateBody => template_body, :Parameters => task_hash["vm"]["driver"]["driveroptions"]["template_parameters"] })

        # grab the id of the stack
        abort("ERROR: Stack creation failed with error #{stack_info.status}. Full response: #{stack_info.ai}") unless stack_info.status == 200
        stack_id = stack_info.body["StackId"]

        # write the result.
        File.open(File.join("#{@hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name, "result"), 'w') { |file| file.write(stack_name) }

        puts("Created stack #{stack_name} with id #{stack_id}")
    end

    def clean hive_location, task_name, task_hash, debug
        abort("ERROR: No local stack record for #{task_name}") unless FileTest.exist?(File.join("#{@hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name, "result"))
        
        aws_key_id = task_hash["vm"]["driver"]["driveroptions"]["access_key_id"] 
        aws_secret = task_hash["vm"]["driver"]["driveroptions"]["secret_access_key"] 

        abort("AWS key id is not specified in task") unless aws_key_id != nil
        abort("AWS secret is not specified in task") unless aws_secret != nil

        puts("Cleaning task #{task_name} ...")

        # run fog cleanup on the stack.
        stack_name = File.read(File.join("#{@hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name, "result"))

        cf = CloudFormation.new(
            :aws_access_key_id => aws_key_id,
            :aws_secret_access_key => aws_secret
        )

        stack_info = cf.delete_stack(stack_name)
        abort("ERROR: could not delete stack #{stack_name}") unless stack_info.status == 200

        File.delete(File.join("#{@hive_location}", "driver", task_hash["vm"]["driver"]["drivertype"], task_name, "result"))
        puts("Deleted stack #{stack_name}")
    end

    def halt hive_location, task_name, task_hash, debug
        abort("ERROR: Halt is not implemented for CloudFormation!")
    end

    def task_schema
        return nil
    end

    def option_schema
        return File.open(File.join("#{File.dirname(__FILE__)}", "..", "..", "resources", "option_schema.template"), 'r').read
    end

    def folder_schema
        return nil
    end

    def port_schema
        return nil
    end

    def ssh_schema
        return nil
    end
end

