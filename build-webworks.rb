#!/bin/usr/env ruby

def help
    puts "Usage:"
    puts "    bww command device options"

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

if __FILE__ == $0
    if ARGV[0].nil?
       help() 
    else
        opt_parser.parse ARGV
    end
end
