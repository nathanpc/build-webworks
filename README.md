# bww

Script to easily build your awesome BlackBerry WebWorks applications.

# Installation

To install this script all you need is to move the **bww** executable and the **build-webworks.rb** to your **/bin/**. The recommended is to clone the repo someone in your computer and then create a link using `ln` to **/bin** so you can still get the updated via `git pull`.

# Configuration

To compile your applications **bww** requires you to have a file called **build.json** inside the current working directory, which should be your application folder. Here's an example of this file:

    {
        "smartphone": {
            "sdk": {
                "location": "/Developer/SDKs/Research\ In\ Motion/BlackBerry\ WebWorks\ SDK\ 2.3.1.5/",
                "sign_password": "somepass"
            },
            "password": ""
        },
        "playbook": {
            "sdk": {
                "location": "/Developer/SDKs/Research\ In\ Motion/BlackBerry\ WebWorks\ SDK\ for\ TabletOS\ 2.2.0.5/",
                "sign_password": "somepass"
            },
            "ip": "169.254.10.25",
            "password": "pass"
        },
        "bb10": {
            "sdk": {
                "location": "/Developer/SDKs/Research\ In\ Motion/BlackBerry\ 10\ WebWorks\ SDK\ 1.0.3.8/",
                "sign_password": "somepass"
            },
            "ip": "169.254.10.25",
            "password": "pass"
        }
    }

# Executing

Here's the script help/usage output:

    Usage:
        bww command device option

    Commands:
        build	Build a unsigned package
        sign	Sign the packages in the current directory
        send	Send your application to the device
        dist	Build and sign your application for distribution
        run		Build, sign, and deploy your application to the device
        clean	Remove all the files created this script

    Devices:
        smartphone	BlackBerry 7 or older
        playbook	BlackBerry PlayBook
        bb10	BlackBerry 10

    Options:
        debug	Enables Remote Web Inspector
