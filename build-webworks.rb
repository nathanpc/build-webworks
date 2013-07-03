#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'fileutils'
require 'term/ansicolor'

class String
	include Term::ANSIColor
end

def help
	puts "Usage:"
	puts "    bww command device [option]"

	puts "\nCommands:"
	puts "    build\tBuild a unsigned package"
	puts "    sign\tSign the packages in the current directory"
	puts "    send\tSend your application to the device"
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

def generate_zip(device, project_name)
	puts "Generating archive".bold

	clean()
	Dir.mkdir File.join(Dir.pwd, "build/")
	unless system "zip -r build/#{project_name}#{device}.zip * -x build/ build.json"
		abort "An error ocurried while trying to generate the archive".red.bold
	end
	puts "Archive generated".green.bold
end

def build(device, option, config, sign, project_name)
	sdk = config[device]["sdk"]
	bbwp = bbwp = File.join(sdk["location"], "bbwp")
	build_id = 1
	debug = ""

	if device == "playbook"
		bbwp = File.join(sdk["location"], "bbwp/bbwp")
	end

	if option == "debug"
		puts "Debug mode enabled".bold
		debug = "-d"
	end

	puts "Compiling application".bold
	build_id = check_build()
	if sign
		if device == "smartphone"
			unless system "'#{bbwp}' build/#{project_name}#{device}.zip -g #{sdk["sign_password"]} -o build/ #{debug}"
				abort "An error ocurried while trying to compile the COD".red.bold
			end
		else
			unless system "'#{bbwp}' build/#{project_name}#{device}.zip -g #{sdk["sign_password"]} -buildId #{build_id} -o build/ #{debug}"
				abort "An error ocurried while trying to compile the BAR".red.bold
			end
		end
	else
		unless system "'#{bbwp}' build/#{project_name}#{device}.zip -o build/ #{debug}"
			abort "An error ocurried while trying to compile the BAR".red.bold
		end
	end
	puts "Application compiled".green.bold
end

def sign(device, config, project_name)
	sdk = config[device]["sdk"]
	signer = ""

	if device == "smartphone"
		abort "Still not implemented. Use the dist command to do this.".red.bold  # TODO: Find a way to *only sign* smartphone apps, not full bbwp -g
	elsif device == "playbook"
		signer = File.join(sdk["location"], "bbwp/blackberry-tablet-sdk/bin/blackberry-signer")
	elsif device == "bb10"
		signer = File.join(sdk["location"], "dependencies/tools/bin/blackberry-signer")
		device = "device/bb10"
	end

	puts "Signing application".bold
	build_id = check_build()
	unless system "'#{signer}' -storepass #{sdk["sign_password"]} build/#{project_name}#{device}.bar"
		abort "An error ocurried while trying to compile the BAR".red.bold
	end
	puts "Application signed".green.bold
end

def run(device, config, project_name)
	sdk = config[device]["sdk"]
	runner = ""

	if device ==  "smartphone"
		password = config[device]["password"]

		if password != ""
			runner = "'#{File.join(sdk["location"], "bin/javaloader")}' -w#{password} load build/StandardInstall/#{project_name}#{device}.cod"
		else
			runner = "'#{File.join(sdk["location"], "bin/javaloader")}' load build/StandardInstall/#{project_name}#{device}.cod"
		end
	elsif device == "playbook"
		runner = "'#{File.join(sdk["location"], "bbwp/blackberry-tablet-sdk/bin/blackberry-deploy")}' -installApp -password #{config[device]["password"]} -device #{config[device]["ip"]} -package build/#{project_name}#{device}.bar"
	elsif device == "bb10"
		runner = "'#{File.join(sdk["location"], "dependencies/tools/bin/blackberry-deploy")}' -installApp -password #{config[device]["password"]} -device #{config[device]["ip"]} -package build/device/#{project_name}#{device}.bar"
	end

	puts "Sending application to device".bold
	unless system runner
		abort "An error ocurried while trying to compile the BAR".red.bold
	end
	puts "Application sent".green.bold
end

def parse_params(command, device, option, config)
	project_name = File.basename(File.expand_path("..", Dir.pwd))

	case command
		when "build"
			# Just build
			generate_zip device, project_name
			print "\n"
			build device, option, config, false, project_name
		when "sign"
			# Just sign
			sign device, config, project_name
		when "send"
			# Just send to device
			run device, config, project_name
		when "dist"
			# Do all for distribution
			generate_zip device, project_name
			print "\n"
			build device, option, config, true, project_name
		when "run"
			# Do all and run
			generate_zip device, project_name
			print "\n"
			build device, option, config, true, project_name
			print "\n"
			run device, config, project_name
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

			puts "\nSuccess!".green.bold
		end
	end
end
