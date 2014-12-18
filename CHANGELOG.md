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
