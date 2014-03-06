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
        @template = task_hash["vm"]["driver"]["driveroptions"]["template"]
        @driver = task_hash["vm"]["driver"]["drivertype"] 
        @hive_location = hive_location
    end

    def render
        puts ("Rendering driver templates...")

        # write cloudformation template to a separate file
        abort("CLoudFormation template not specified!") unless @template != nil

        puts ("Writing #{File.join(@hive_location, "driver", @driver, @name, "template.json")}...")
        FileUtils.mkdir_p(File.join(@hive_location, "driver", @driver, @name))
        File.open(File.join("#{@hive_location}", "driver", @vm["driver"]["drivertype"], @name, "template.json"), 'w') { |file| file.write(@template) }
    end
end
