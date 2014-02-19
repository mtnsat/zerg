require 'zerg'

# give this class the name you want for your command zergrush_vagrant
class Vagrant < ZergGemPlugin::Plugin "/driver"
    def rush
        puts "rush!"
    end

    def clean
        puts "clean!"
    end

    def halt
        puts "halt!"
    end
end

