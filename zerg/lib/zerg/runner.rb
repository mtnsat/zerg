require 'awesome_print'
require 'json-schema'
require 'fileutils'

module Zerg
    class Runner

        # cross platform way of checking if command is available in PATH
        def which(cmd)
            exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
            ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
                exts.each { |ext|
                exe = File.join(path, "#{cmd}#{ext}")
                return exe if File.executable? exe
                }
            end
          return nil
        end

        def self.rush(task)
            puts "ZERG RUSH #{task}!"
        end
    end
end