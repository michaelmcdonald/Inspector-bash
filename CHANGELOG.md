**1.06 -- 12/14/2014**

Re-wrote most of the logic for determining the MySQL InnoDB_Buffer_Pool_size and MyISAM Key_Buffer
values. The previous logic could not handle values that were denoted as "#G" and any such values
would create invalid output of the script. The new logic examines the value and detects any type
of memory denomination (the valid ones being "M" or "G") and if those are present it responds 
accordingly. The previous logic to compute the value if entered in Bytes is still present.

**1.05 -- 12/14/2014**

Fixed the regex for the Apache version number so that it would show up properly on CentOS 7 boxes.

**1.04 -- 12/14/2014**

Corrected the issue where the PHP memory_limit value was only report in "MB". Now it properly grabs the 
memory denomination and uses that to display the appropriate memory value.

**1.03 -- 12/14/2014**

Overhauled the PHP handler section as discussed in 1.01. This should (theoretically) work on Core-Managed and
Fully Managed (see: cPanel) servers for the major PHP handlers (need to look into PHP-FPM since it is being
used more frequently). There is still some testing to be had on Core-Managed and Ubuntu machines, but overall
I believe it is fairly solid and cut the runtime of the script in half. Still need to re-write the PHP section 
to ensure that if cPanel is not installed that only certain functions are run. That will come later.

**1.02 -- 12/14/2014**

Corrected the issue on Ubuntu machines where # of CPU cores reported incorrectly.

**1.01 -- 12/13/2014**

Updated phpinfo function to better utilize the PHP version and identify the PHP handler in use. This should now
be independent of whatever version PHP is installed on the system. Unfortunately this still requires cPanel and
the /usr/local/cpanel/bin/rebuild_phpconf --current command. Investigating ways around this and I believe I 
have identified a solution: the /usr/local/apache/conf/php.conf file. This identifies the PHP handler being 
used (at least thanks to cPanel). This has the added benefit of being faster (the rebuild command takes 2.5
seconds to complete) as well as (potentially) being cPanel independent. I will have to test on additional 
systems to see if that is actually the case.

KNOWN ISSUES:

- On Ubuntu machines (NOT supported at this time) there may be an issue whereby CPU(s) are incorrectly calculated.
