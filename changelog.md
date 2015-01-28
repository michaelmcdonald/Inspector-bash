**1.5.3 -- 1/28/2015**

Altered the code that identifies which RAID cards are being used so that older
LSI model cards (which display "LSI" twice) do not throw off the logic that
counts how many RAID cards are present on the system. Thanks, Dooley!

**1.5.2 -- 1/21/2015**

Corrected CentOS version capture string to properly capture double digit minor
version numbers.

**1.5.1 -- 1/19/2015**

Corrected the command(s) that acquired the RAID controller brand as well as how
many controllers were on a system. Older (CentOS 5) systems appeared to be 
running a version of Bash that was unable to process my command as a single line
so I split it into multiple parts. 

Corrected version number to more accurately reflect progress made on major parts
of the script as well as bug fixes. 

**1.1.21 -- 1/19/2015**

Corrected STDERR output for MegaCli commands

**1.1.20 -- 1/18/2015**

Corrected an issue whereby the CPANEL INFO section would display an error if no
cPanel accounts were present.

**1.1.19 -- 1/14/2015**

Corrected an additional spacing issue with DISK INFO section after a controller
type of "N/A".

**1.1.18 -- 1/14/2015**

Corrected spacing issues in the RAID array section between DISK INFO and APACHE
sections as well as fixing spacing issues in the CPU processor output.

**1.1.17 -- 1/13/2015**

Added some logic to test for the PHP binary and left in some profiling functions.

**1.1.16 -- 1/12/2015**

Added components to System Info function to identify the timezone the server is 
set for as well as some simple logic to inform you of the number of users logged
into a machine.

**1.1.15 -- 1/12/2015**

Corrected adaptec array count logic since some controllers start at 0 while others
start at 1. This will now find the appropriate starting value and use that.

**1.1.14 -- 1/12/2015**

Corrected what string I look for in regards to how many LSI arrays there are to
work more accurately with newer and older LSI cards.

**1.1.13 -- 1/12/2015**

Corrected an issue with the LSI RAID logic to correctly display the RAID level for
RAID 5 (and theoretically any other RAID level) since it was only ever going to 
display RAID 1 or RAID 10.

**1.1.12 -- 1/9/2015**

Corrected spacing issue with the PHP info section

**1.1.11 -- 1/9/2015**

Corrected issues with LSI cards not showing appropriate array information.

**1.1.10 -- 1/9/2015**

Cleaned up the disk usage components so that the "on" in "Mounted on" no longer 
is displayed. There were instances where there would be a large game between the
two words and it looked bad. 

**1.1.9 -- 1/9/2015**

Re-wrote the logic concerning RAID controllers / arrays. Inspector Gadget can now
handle multiple RAID cards (of brands Adaptec / LSI) as well as multiple arrays
per controller.

**1.1.8 -- 1/6/2015**

Corrected issue with logic to run Apache and MySQL functions if they are the only
pieces of software installed.

KNOWN ISSUES: multiple RAID cards / RAID arrays do not display correctly. Currently
investigating ways to properly store / display this information. If something is worth
doingn it is worth doing right.

**1.1.7 -- 1/5/2015**

Corrected issue with PHP loaded configuration command (added 2>/dev/null)

KNOWN ISSUES: multiple RAID cards / RAID arrays do not display correctly. Currently
investigating ways to properly store / display this information. If something is worth
doingn it is worth doing right.

**1.1.6 -- 1/4/2015 **

Corrected an issue with the PHP loaded configuration command (using full path to call
php now). 

KNOWN ISSUES: multiple RAID cards / RAID arrays do not display correctly. Currently
investigating ways to properly store / display this information. If something is worth
doingn it is worth doing right.

** 1.1.5 -- 12/27/2014**

Corrected minor issue with the header_color function and the "-a" flag.

** 1.1.4 -- 12/27/2014**

Added a traffic information function that will examine the domlogs for a cPanel server 
and provide useful information in an easy to read format. Still some tweaking I want /
should do to this function so for now it is an unannounced feature. Accessible using the
flag "-t" or "--traffic"; however it will become public once I am satisfied with it.

**1.1.3 -- 12/23/2014**

Corrected an issue where the Nginx function was not showing anything (as discussed in the 
KNOWN ISSUES of v1.1.2). Altered how it was gathering the version output as well as an IF
statement that will prevent it from showing should it not be present.

**1.1.2 -- 12/22/2014**

Corrected my case statement and the function logic in general. There is no a "-nh" option that 
will allow you to mute the header from being displayed on output. 

KNOWN ISSUES: Nginx prints version information to STDERR. Since I redirect the stderr of commands
to prevent unwanted errors on systems where those commands may not exist, we have an issue. 
Currently investigating how to get around this.

**1.1.1 -- 12/20/2014**

Implemented some basic checks for Nginx and Varnish. If present on the system these checks will
display the version of the software present. Not sure if I will add any additional functionality
as there is not much more I can see that would be useful to include.

**1.1.0 -- 12/20/2014**

Have implemented all aspects of the roadmap for v1.1.0 as well as started the foundation for
a menu system / passing options to the script. Basic functionality is there for options and
it should work fine; however I need to test it out on various systems as well as via the remote
call to see if it works as it should.

**1.0.12 -- 12/18/2014**

Corrected an issue whereby SAN mounts would flood the screen with their df data. Since I am
not super concerned with that degree of information I have opted to cut the SAN data from the
df output. May investigate an option where I alert the user that SAN data exists and present
them with an opportunity to display it as well.

**1.0.11 -- 12/18/2014**

Corrected some issues with CentOS 4 not working correct as well as what file older versions
of cPanel used to reference if backups were enabled or not.

**1.0.10 -- 12/18/2014**

Setup an easy to use version variable to update script header while also correcting 
version number schema. Identified that script did NOT work on CentOS 4 due to how
regex was being interpreted. As a result I created a quick check at the beginning
of the scrip to identify CentOS 4 boxes and exit the script if true.

**1.0.9 -- 12/15/2014**

Altered what the MYSQLTEST function looked for so as to better work with Unmanaged servers
and ensure that if Apache / PHP / MySQL were NOT installed that the script would still run.

**1.0.8 -- 12/14/2014**

Corrected numerous issues on Cent7 (which likely would crop up on Core-Managed boxes as well).
Should see improved functionality in the logic if what is / is not installed as it now checks
specifically for PHP as well. Setup a global php.ini checking component as well to ensure the
script is using the properly loaded php.ini file on the system.

**1.0.7 -- 12/14/2014**

Created logic to examine if cPanel, Apache, or MySQL are installed. Depending on what is / is not
installed the various functions that are safe to run will. This still does NOT factor in Ubuntu
which will require some additional logic due to differences in files / file locations.

**1.0.6 -- 12/14/2014**

Re-wrote most of the logic for determining the MySQL InnoDB_Buffer_Pool_size and MyISAM Key_Buffer
values. The previous logic could not handle values that were denoted as "#G" and any such values
would create invalid output of the script. The new logic examines the value and detects any type
of memory denomination (the valid ones being "M" or "G") and if those are present it responds 
accordingly. The previous logic to compute the value if entered in Bytes is still present.

**1.0.5 -- 12/14/2014**

Fixed the regex for the Apache version number so that it would show up properly on CentOS 7 boxes.

**1.0.4 -- 12/14/2014**

Corrected the issue where the PHP memory_limit value was only report in "MB". Now it properly grabs the 
memory denomination and uses that to display the appropriate memory value.

**1.0.3 -- 12/14/2014**

Overhauled the PHP handler section as discussed in 1.01. This should (theoretically) work on Core-Managed and
Fully Managed (see: cPanel) servers for the major PHP handlers (need to look into PHP-FPM since it is being
used more frequently). There is still some testing to be had on Core-Managed and Ubuntu machines, but overall
I believe it is fairly solid and cut the runtime of the script in half. Still need to re-write the PHP section 
to ensure that if cPanel is not installed that only certain functions are run. That will come later.

**1.0.2 -- 12/14/2014**

Corrected the issue on Ubuntu machines where # of CPU cores reported incorrectly.

**1.0.1 -- 12/13/2014**

Updated phpinfo function to better utilize the PHP version and identify the PHP handler in use. This should now
be independent of whatever version PHP is installed on the system. Unfortunately this still requires cPanel and
the /usr/local/cpanel/bin/rebuild_phpconf --current command. Investigating ways around this and I believe I 
have identified a solution: the /usr/local/apache/conf/php.conf file. This identifies the PHP handler being 
used (at least thanks to cPanel). This has the added benefit of being faster (the rebuild command takes 2.5
seconds to complete) as well as (potentially) being cPanel independent. I will have to test on additional 
systems to see if that is actually the case.

KNOWN ISSUES:

- On Ubuntu machines (NOT supported at this time) there may be an issue whereby CPU(s) are incorrectly calculated.
