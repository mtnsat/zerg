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

module Zerg
    class Runner
        def self.rush(task, debug)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # rush!
            begin
                pmgr = ZergGemPlugin::Manager.instance
                pmgr.load
                puts "/driver/#{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]}"
                driver = pmgr.create("/driver/#{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]}")
                driver.rush Zerg::Hive.instance.load_path, task, Zerg::Hive.instance.hive[task], debug
            rescue ZergGemPlugin::PluginNotLoaded
                abort("ERROR: driver #{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]} not found. Did you install the plugin gem?")
            end
            puts("SUCCESS!")
        end

        def self.halt(task, debug)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            # halt!
            begin
                pmgr = ZergGemPlugin::Manager.instance
                pmgr.load
                driver = pmgr.create("/driver/#{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]}")
                driver.halt Zerg::Hive.instance.load_path, task, Zerg::Hive.instance.hive[task], debug
            rescue ZergGemPlugin::PluginNotLoaded
                abort("ERROR: driver #{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]} not found. Did you install the plugin gem?")
            end
            puts("SUCCESS!")
        end

        def self.clean(task, debug)
            # load the hive first
            Zerg::Hive.instance.load

            puts "Loaded hive. Looking for task #{task}..."
            abort("ERROR: Task #{task} not found in current hive!") unless Zerg::Hive.instance.hive.has_key?(task) 

            begin
                pmgr = ZergGemPlugin::Manager.instance
                pmgr.load
                driver = pmgr.create("/driver/#{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]}")
                driver.clean Zerg::Hive.instance.load_path, task, Zerg::Hive.instance.hive[task], debug
            rescue ZergGemPlugin::PluginNotLoaded
                abort("ERROR: driver #{Zerg::Hive.instance.hive[task]["vm"]["driver"]["drivertype"]} not found. Did you install the plugin gem?")
            end
            puts("SUCCESS!")
        end
    end
end