#!/bin/usr/env ruby

require 'rubygems'
require 'json'
require 'fileutils'
require 'term/ansicolor'

class String
    include Term::ANSIColor
end

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

def device_arg_exists?(device)
    unless device == "smartphone" || device == "playbook" || device == "bb10"
        abort "You haven't specified the desired device to target the build."
    end
end

def clean
    FileUtils.rm_r File.join(Dir.pwd, "build/"), :force => true
end

def build_zip(device)
    Dir.mkdir File.join(Dir.pwd, "build/")
    exec "zip -r build/#{device}.zip * -x build/ build.json"
end

def check_build
    id_file = File.join(Dir.pwd, ".buildid")
    build_id = 1

    if File.exists? id_file
        current_id = File.read(id_file)

        File.open(id_file, "w+") do |file|
            #puts file.inspect
            build_id = Integer(current_id) + 1
            file.write build_id.to_s
        end
    else
        File.open(id_file, "w+") do |file|
            file.write build_id
        end
    end

    return build_id
end

def build(device, option, config)
    sdk = config[device]["sdk"]
    build_id = 1

    puts "Generating archive".bold
    clean()
    build_zip device

    puts "\nCompiling BAR".bold
    build_id = check_build()
    exec "#{File.join(sdk["location"], "bbwp")} build/#{device}.zip -buildId #{build_id} -o build/"
end

def parse_params(command, device, option, config)
    case command
        when "build"
            build device, option, config
        when "sign"
        when "deploy"
        when "dist"
        when "run"
        when "clean"
            clean()
            puts "Cleaned the mess."
        else
            help()
    end
end

if __FILE__ == $0
    if ARGV[0].nil?
       help() 
    else
        command = ARGV[0]
        device = ARGV[1]
        option = ARGV[2]

        if command == "clean"
            parse_params command, nil, nil, nil
        else
            config = parse_config()
            unless device == "smartphone" || device == "playbook" || device == "bb10"
                abort "You haven't specified the desired device to target the build."
            end

            parse_params command, device, option, config
        end
    end
end
