Inspector-bash
====

Inspector Gadget (also known as “Inspector”) is a script written in Bash that quickly gathers information about various aspects of a system and displays that information in a clean and easily digestible format. This was primarily created for use at Liquid Web; however it should work without issue on any server that meets the compatibility requirements.

Compatibility:

* cPanel systems 11.32 and higher
* MySQL 5.0 and higher (not tested on 4.x, yet)
* Apache 2.2 / 2.4
* PHP 5.x and higher (not tested on 4.x, yet)
* CentOS 4.x, 5.x, 6.x, 7.x
* Ubuntu systems are NOT fully supporeted at this time
* Plesk systems are NOT supported at this time

Download/Installation
--

The source for Inspector Gadget is open and available via Github. Feel free to clone the repo, make changes, and offer up pull requests for any features you would like to see. The simplest and shortest method of using Inspector Gadget is:

    bash <(curl -skL inspector.sh)

Alternatively you can run it by downloading it locally:

    wget http://inspector.sh/ -O inspector.sh
    bash inspector.sh

Of course, you can add the execute bit (chmod +x inspector.sh) so you can execute it without calling bash directly.

Additionally you can utilize some arguments at the command line to have Inspector Gadget only run certain functions. The following is the help menu that can also be triggered with the "-h" flag or "--help":

Help documentation for Inspector Gadget.

Command line switches are optional. The following switches are recognized.
-a | --all     --Runs all functions. This is the default behavior.
-s | --system  --Runs hardware related functions ONLY.
-c | --core    --Runs software related functions ONLY.
-h | --help    --Displays this help message. No further functions are performed.

Example: ./inspector.sh -c
Example: bash <(curl -skL inspector.sh) -s

FAQ
--

Question: Will Inspector Gadget change anything on my system?

**No.** Inspector Gadget is a read only script. It will not write to any configuration files, change the status of any daemons, or call your mother to wish her a happy birthday. It will give you an overview of hardware and software on a server after it completes.

Question: Can I run this script and know what’s going on?

Inspector Gadget will not replace actual investigative work on a server in any form or fashion. You will need to know what you’re looking at and what it means to get any use out of this script. This is simply meant to provide you with a great deal of information quickly and in a format you can easily read / understand. If you don’t know what you’re looking at you should ask and seek help before making any changes.

Question: Why doesn’t Inspector Gadget have X feature?

The script is constantly being worked on; however at some point I had to make a decision to call it feature complete and push it out into the open. As time goes on I will be updating the script to add additional functionality and compatibility. See the ROADMAP.txt file for additional information about planned features.

Question: It's not working on this system! What gives?!

These kinds of things are bound to happen. Here are the details I need from you in order to research the problem thoroughly:

* OS and OS version
* Exact MySQL, cPanel, Apache, and PHP versions (if present)
* The disk setup / RAID array + controller (if present)
* How you were executing the script
* The full text of any errors present

Then email that information to michael@liquidweb.com
