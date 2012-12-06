#!/bin/usr/env ruby

require 'rubygems'
require 'json'


def help
    puts "Usage:"
    puts "    bww command device option"

    puts "\nCommands:"
    puts "    build\tBuild a unsigned package"
    puts "    sign\tSign the packages in the current directory"
    puts "    deploy\tDeploy your application to the device"
    puts "    dist\tBuild and sign your application for distribution"
    puts "    run\t\tBuild, sign, and deploy your application to the device"
    puts "    clean\tRemove all the files created this script"

    puts "\nDevices:"
    puts "    smartphone\tBlackBerry 7 or older"
    puts "    playbook\tBlackBerry PlayBook"
    puts "    bb10\tBlackBerry 10"

    puts "\nOptions:"
    puts "    debug\tEnables Remote Web Inspector"
end

def parse_config
    config_location = File.join(Dir.pwd, "build.json")

    if File.exists?(config_location)
        return JSON.parse File.read(config_location)
    else
        abort "Couldn't find the build.conf configuration file in your current directory"
    end
end

def parse_params(command, device, option)
    case command
        when "build"
            config = parse_config()
        when "sign"
            config = parse_config()
        when "deploy"
            config = parse_config()
        when "dist"
            config = parse_config()
        when "run"
            config = parse_config()
        when "clean"
            #
        else
            help()
    end

    puts Dir.pwd
end

if __FILE__ == $0
    if ARGV[0].nil?
       help() 
    else
        parse_params ARGV[0], ARGV[1], ARGV[2]
    end
end
