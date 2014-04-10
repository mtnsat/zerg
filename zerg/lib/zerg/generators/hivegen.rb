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

require 'thor/group'
module Zerg
    module Generators
        class HiveGen < Thor::Group
            include Thor::Actions

            class_option :force, :type => :boolean

            def self.source_root
                File.join(File.dirname(__FILE__), "task")
            end

            def create_hive
                load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", ".hive") : File.join("#{ENV['HIVE_CWD']}", ".hive")
                empty_directory "#{File.join(load_path, "driver")}"
            end

            def copy_sample_task
                load_path = (ENV['HIVE_CWD'] == nil) ? File.join("#{Dir.pwd}", ".hive") : File.join("#{ENV['HIVE_CWD']}", ".hive")
                template("template.ke", "#{File.join(load_path, "helloworld", "helloworld.ke")}")
                template("awstemplate.ke", "#{File.join(load_path, "helloaws", "helloaws.ke")}")
            end
        end
    end
end