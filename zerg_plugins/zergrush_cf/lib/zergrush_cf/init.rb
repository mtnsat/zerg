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
        aws_key_id = task_hash["vm"]["driver"]["driveroptions"][0]["access_key_id"] 
        aws_secret = task_hash["vm"]["driver"]["driveroptions"][0]["secret_access_key"] 

        # eval possible environment variables
        if aws_key_id =~ /^ENV\['.+'\]$/
            aws_key_id = eval(aws_key_id)
        end

        if aws_secret =~ /^ENV\['.+'\]$/
            aws_secret = eval(aws_secret)
        end

        abort("AWS key id is not specified in task") unless aws_key_id != nil
        abort("AWS secret is not specified in task") unless aws_secret != nil

        renderer = ZergrushCF::Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        template_body = renderer.render

        # see if we need to upload anything to s3?
        if task_hash["vm"]["driver"]["driveroptions"][0]["storage"] != nil
            if task_hash["vm"]["driver"]["driveroptions"][0]["storage"]["s3_bucket"] != nil 
                bucket_name = task_hash["vm"]["driver"]["driveroptions"][0]["storage"]["s3_bucket"]["name"]
                is_public = task_hash["vm"]["driver"]["driveroptions"][0]["storage"]["s3_bucket"]["public"]
                files = task_hash["vm"]["driver"]["driveroptions"][0]["storage"]["s3_bucket"]["files"]

                # create a connection
                connection = Fog::Storage.new({
                    :provider => 'AWS',
                    :aws_access_key_id => aws_key_id,
                    :aws_secret_access_key => aws_secret
                })

                directory = connection.directories.create(
                    :key => bucket_name,
                    :public => is_public
                )

                files.each { |file|
                    directory.files.create(
                        :key    => file,
                        :body   => File.open(File.join(hive_location, task_name, file)),
                        :public => is_public
                    )
                }
            end
        end

        cf = Fog::AWS::CloudFormation.new(
            :aws_access_key_id => aws_key_id,
            :aws_secret_access_key => aws_secret
        )

        # create the cloudformation stack
        stack_name = "#{task_name}"

        params = eval_params(task_hash["vm"]["driver"]["driveroptions"][0]["template_parameters"])       
        stack_info = cf.create_stack(stack_name, { 'DisableRollback' => true, 'TemplateBody' => template_body.to_json, 'Parameters' => params, 'Capabilities' => [ "CAPABILITY_IAM" ] })

        # grab the id of the stack
        stack_id = stack_info.body["StackId"]
        puts("Creating stack #{stack_name} with id #{stack_id}")


        # get the event collection and initial info
        outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
        while outputs_info == nil do
            sleep 1 
            outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
        end

        events = cf.describe_stack_events(stack_name).body['StackEvents']
        while events == nil do
            sleep 1 
            events = cf.describe_stack_events(stack_name).body['StackEvents']
        end

        event_counter = 0
        while outputs_info.body["Stacks"][0]["StackStatus"] == "CREATE_IN_PROGRESS" do
            logEvents(events.first(events.length - event_counter))
            event_counter = events.length

            events = cf.describe_stack_events(stack_name).body['StackEvents']
            outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
            if outputs_info.body["Stacks"][0]["StackStatus"] == "CREATE_COMPLETE"
                logEvents(events.first(events.length - event_counter))
                puts("Stack outputs:")
                ap outputs_info.body["Stacks"][0]["Outputs"]
                return 0
            end
        end

        abort("ERROR: Failed with stack status: #{outputs_info.body["Stacks"][0]["StackStatus"]}")
        
        rescue Fog::Errors::Error => fog_cf_error
            abort ("ERROR: AWS error: #{fog_cf_error.message}")
    end

    def clean hive_location, task_name, task_hash, debug
        
        aws_key_id = task_hash["vm"]["driver"]["driveroptions"][0]["access_key_id"] 
        aws_secret = task_hash["vm"]["driver"]["driveroptions"][0]["secret_access_key"]

        # eval possible environment variables
        if aws_key_id =~ /^ENV\['.+'\]$/
            aws_key_id = eval(aws_key_id)
        end

        if aws_secret =~ /^ENV\['.+'\]$/
            aws_secret = eval(aws_secret)
        end 

        abort("AWS key id is not specified in task") unless aws_key_id != nil
        abort("AWS secret is not specified in task") unless aws_secret != nil

        puts("Cleaning task #{task_name} ...")

        # run fog cleanup on the stack.
        stack_name = "#{task_name}"

        cf = Fog::AWS::CloudFormation.new(
            :aws_access_key_id => aws_key_id,
            :aws_secret_access_key => aws_secret
        )

        stack_info = cf.delete_stack(stack_name)
        puts("Deleting stack #{stack_name}")

         # get the event collection and initial info
        outputs_info = nil
        while outputs_info == nil do
            sleep 1 
            begin
                outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
            rescue Fog::AWS::CloudFormation::NotFound
                return 0
            end
        end

        events = cf.describe_stack_events(stack_name).body['StackEvents']
        while events == nil do
            sleep 1
            begin
                events = cf.describe_stack_events(stack_name).body['StackEvents']
            rescue Fog::AWS::CloudFormation::NotFound
                return 0
            end
        end

        event_counter = 0
        while outputs_info.body["Stacks"][0]["StackStatus"] == "DELETE_IN_PROGRESS" do
            logEvents(events.first(events.length - event_counter))
            event_counter = events.length
            begin
                events = cf.describe_stack_events(stack_name).body['StackEvents']
                outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
            rescue Fog::AWS::CloudFormation::NotFound
                logEvents(events.first(events.length - event_counter))
                return 0
            end
        end

        abort("ERROR: Failed with stack status: #{outputs_info.body["Stacks"][0]["StackStatus"]}")
    
        rescue Fog::Errors::Error => fog_cf_error
            abort ("ERROR: AWS error: #{fog_cf_error.ai}")
    end

    def logEvents events
        events.each do |event|
            puts "Timestamp: #{event['Timestamp']}"
            puts "LogicalResourceId: #{event['LogicalResourceId']}"
            puts "ResourceType: #{event['ResourceType']}"
            puts "ResourceStatus: #{event['ResourceStatus']}"
            puts "ResourceStatusReason: #{event['ResourceStatusReason']}" if event['ResourceStatusReason']
            puts "--"
        end
    end

    def halt hive_location, task_name, task_hash, debug
        puts("Halt is not implemented for CloudFormation.")
        return
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

    def eval_params(params)
        params.each do |k, v|
            # If v is nil, an array is being iterated and the value is k. 
            # If v is not nil, a hash is being iterated and the value is v.
            # 
            value = v || k

            if value.is_a?(Hash) || value.is_a?(Array)
                eval_params(value)
            else
                if value.is_a?(String)
                    if value =~ /(^ENV\['.+'\]$)/
                        if v.nil?
                            k.replace eval(value)
                        else
                            params[k] = eval(value)
                        end
                    end
                end
            end
        end

        return params
    end
end

