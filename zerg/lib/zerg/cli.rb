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

require 'thor'
require 'zerg'
require 'zerg/generators/hivegen'

module Zerg
    class HiveCLI < Thor
        class_option :force, :type => :boolean, :banner => "force overwrite of files" 

        # hack (https://github.com/erikhuda/thor/issues/261#issuecomment-16880836)
        # to get around thor showing klass name snake case in subcommand help (instead of subcommand name) 
        package_name "hive"
        def self.banner(command, namespace = nil, subcommand = false)
            "#{basename} #{@package_name} #{command.usage}"
        end

        desc "verify", "verifies hive tasks without loading them"
        def verify
            puts Zerg::Hive.verify
        end

        desc "list", "lists hive tasks"
        def list
            puts Zerg::Hive.list
        end

        desc "import [FILE]", "import a .ke file into the hive folder"
        def import(file)
            puts Zerg::Hive.import(file, options[:force])
        end

        desc "remove [TASK]", "remove a task from hive"
        def remove(file)
            puts Zerg::Hive.remove(file, options[:force])
        end
    end

    class CLI < Thor 
        class_option :force, :type => :boolean, :banner => "force overwrite of files" 
        class_option :debug, :type => :boolean, :banner => "add debug option to driver" 
        class_option :base, :type => :string, :banner => "base name for the snapshot"  

        def self.exit_on_failure?
            true
        end

        desc "init", "initializes new hive"
        def init
            puts Zerg::Generators::HiveGen.start
        end

        desc "rush [TASK]", "runs a task from hive"
        def rush(task)
            puts Zerg::Runner.rush(task, options[:debug])
        end

        desc "clean [TASK]", "cleans a task"
        def clean(task)
            puts Zerg::Runner.clean(task, options[:debug])
        end 

        desc "halt [TASK]", "stops all task vm instances"
        def halt(task)
            puts Zerg::Runner.halt(task, options[:debug])
        end

        desc "snapshot [TASK]", "takes a snapshot of currently running vms"
        def snapshot(task)
            puts Zerg::Runner.snapshot(task, options[:base])
        end
          
        register(HiveCLI, 'hive', 'hive [COMMAND]', 'Manage hive - a collection of task descriptions.')
    end
end