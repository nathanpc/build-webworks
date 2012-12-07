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
        abort "Couldn't find the build.conf configuration file in your current directory".red
    end
end

def device_arg_exists?(device)
    unless device == "smartphone" || device == "playbook" || device == "bb10"
        abort "You haven't specified the desired device to target the build.".red
    end
end

def clean
    FileUtils.rm_r File.join(Dir.pwd, "build/"), :force => true
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

def generate_zip(device)
    puts "Generating archive".bold

    clean()
    Dir.mkdir File.join(Dir.pwd, "build/")
    unless system "zip -r build/#{device}.zip * -x build/ build.json"
        abort "An error ocurried while trying to generate the archive".red.bold
    end
end

def build(device, option, config)
    sdk = config[device]["sdk"]
    bbwp = bbwp = File.join(sdk["location"], "bbwp")
    build_id = 1
    debug = ""

    if device == "playbook"
        bbwp = File.join(sdk["location"], "bbwp/bbwp")
    end

    if config == "debug"
        debug = "-d"
    end

    puts "Compiling application".bold
    build_id = check_build()
    unless system "'#{bbwp}' build/#{device}.zip -buildId #{build_id} -o build/ #{debug}"
        abort "An error ocurried while trying to compile the BAR".red.bold
    end
end

def sign(device)
    sdk = config[device]["sdk"]
    signer = ""

    if device == "smartphone"
        abort "Still not implemented.".red.bold  # TODO: Find a way to *only sign* smartphone apps, not full bbwp -g
    elsif device == "playbook"
        signer = File.join(sdk["location"], "bbwp/blackberry-tablet-sdk/bin/blackberry-signer")
    elsif device == "bb10"
        signer = File.join(sdk["location"], "bbwp/dependencies/tools/bin/blackberry-signer")
    end

    puts "Signing application".bold
    build_id = check_build()
    unless system "'#{signer}' -storepass #{sdk["sign_password"]} build/#{device}.bar"
        abort "An error ocurried while trying to compile the BAR".red.bold
    end
end

def parse_params(command, device, option, config)
    case command
        when "build"
            # Just build
            generate_zip device
            build device, option, config
        when "sign"
            # Just sign
            sign device
        when "deploy"
            # Just send to device
        when "dist"
            # Do all for distribution
            generate_zip device
            build device, option, config
            sign device
        when "run"
            # Do all and run
        when "clean"
            # Clean the mess
            clean()
            puts "Cleaned the mess."
        else
            # No need to explain
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
                abort "You haven't specified the desired device to target the build.".red
            end

            parse_params command, device, option, config
        end
    end
end
