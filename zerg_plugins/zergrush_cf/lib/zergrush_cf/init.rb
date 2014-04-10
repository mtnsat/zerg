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
require 'ruby-progressbar'
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

        progressbar = nil
        params = eval_params(task_hash["vm"]["driver"]["driveroptions"][0]["template_parameters"])       
        stack_info = cf.create_stack(stack_name, { 'DisableRollback' => true, 'TemplateBody' => template_body.to_json, 'Parameters' => params, 'Capabilities' => [ "CAPABILITY_IAM" ] })

        # grab the id of the stack
        stack_id = stack_info.body["StackId"]
        puts("Creating stack #{stack_name} with id #{stack_id}\n-----------------------------")
        progressbar = ProgressBar.create(:starting_at => 20, :total => nil)

        # get stack outputs
        outputs_info = cf.describe_stacks({ 'StackName' => stack_name })

        until outputs_info.body["Stacks"][0]["StackStatus"] != "CREATE_IN_PROGRESS" do
            progressbar.increment
            sleep 2

            outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
        end
        progressbar.stop
        abort "ERROR: Stack #{stack_name} creation failed. Refer to AWS CloudFormation console for further info." unless outputs_info.body["Stacks"][0]["StackStatus"] == "CREATE_COMPLETE"
        
        puts("SUCCESS! Stack outputs:")
        ap outputs_info.body["Stacks"][0]["Outputs"]

        rescue Fog::Errors::Error => fog_cf_error
            progressbar.stop unless progressbar == nil
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

        progressbar = nil

        stack_info = cf.delete_stack(stack_name)
        puts("Deleting stack #{stack_name}")
        progressbar = ProgressBar.create(:starting_at => 20, :total => nil)
        outputs_info = cf.describe_stacks({ 'StackName' => stack_name })

        while outputs_info.body["Stacks"][0]["StackStatus"] == "DELETE_IN_PROGRESS" do
            progressbar.increment
            sleep 2

            begin
                outputs_info = cf.describe_stacks({ 'StackName' => stack_name })
            rescue Fog::AWS::CloudFormation::NotFound
                progressbar.stop
                break
            end
        end

        rescue Fog::AWS::CloudFormation::NotFound
            progressbar.stop unless progressbar == nil
            abort ("ERROR: Stack #{stack_name} was not found in AWS.")
        rescue Fog::Errors::Error => fog_cf_error
            progressbar.stop unless progressbar == nil
            abort ("ERROR: AWS error: #{fog_cf_error.ai}")
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

