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
require 'rbconfig'
require_relative 'renderer'

class CloudFormation < ZergGemPlugin::Plugin "/driver"
    def rush hive_location, task_name, task_hash, debug
        puts ("Will perform task #{task_name} with contents:\n #{task_hash.ai}")

        renderer = Renderer.new(
            hive_location, 
            task_name, 
            task_hash)        
        renderer.render

    end

    def clean hive_location, task_name, task_hash, debug
        puts("Cleaning task #{task_name} ...")

        # run fog cleanup on the stack.
        
    end

    def halt hive_location, task_name, task_hash, debug
        puts("Halt is not implemented for CloudFormation ...")
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

