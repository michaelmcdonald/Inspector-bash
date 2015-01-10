#!/bin/bash

#   TITLE: Inspector Gadget
#  AUTHOR: michael mcdonald
# CONTACT: michael@liquidweb.com
# PURPOSE: to examine various aspects of a Linux system and provide
#          quick access to that information in a clean format


# Special thanks to James Dooley for peer reviewing my work and offering
# numerous suggestions on how to improve / speed up my bash scripting
# within this script and the predecessor of it.


##################################################################################

# Quick place to set the script's version number (adjusts the header version too)
SCRIPTVERSION="v1.1.12"


##################################################################################
#                                 BEGIN  VARIABLES                               #
##################################################################################



# Various color variables used throughout the script

HEADERINFO=$(tput setaf 2)
MEMORYINFO=$(tput setaf 180)
SYSTEMINFO=$(tput setaf 124)
DISKINFO=$(tput setaf 100)
TRAFFICINFO=$(tput setaf 210)
CPANELINFO=$(tput setaf 172)
MYSQLINFO=$(tput setaf 74)
APACHEINFO=$(tput setaf 5)
NGINXINFO=$(tput setaf 34)
VARNISHINFO=$(tput setaf 117)
PHPINFO=$(tput setaf 140)
RECOMMENDATIONS=$(tput setaf 42)
SECURITYINFO=$(tput setaf 227)
ISSUE=$(tput setaf 196)
ITEMOK=$(tput setaf 2)
IGNORE=$(tput setaf 32)

UNDERLINE=$(tput smul)

ORANGE=$(tput setaf 202)
YELLOW=$(tput setaf 226)

RESET=$(tput sgr0)


# Global variables that any function can use

ACTUALPHPINI=$(/usr/local/bin/php -i 2>/dev/null | grep "Loaded Configuration File" | awk '{print $5}')


##################################################################################
#                                 END VARIABLES                                  #
##################################################################################




##################################################################################
#                              BEGIN  SOFTWARE CHECKS                            #
##################################################################################

# Quick check against a file that will verify if Apache IS installed or is NOT installed. This is stored in a variable
APACHETEST=$(cat /etc/httpd/conf/httpd.conf 2>/dev/null)

# Quick check against a file that will verify if MySQL IS installed or is NOT installed. This is stored in a variable
#MYSQLTEST=$(mysql -e ' SELECT VERSION(); ' 2>/dev/null)
MYSQLTEST=$(mysql -V 2>/dev/null)

PHPTEST=$(php -i 2>/dev/null | grep "Loaded Configuration File" | awk '{print $5}')

# Quick check against a file that will verify if cPanel IS or is NOT installed. This is stored in a variable
CPANELTEST=$(cat /usr/local/cpanel/version 2>/dev/null)


##################################################################################
#                               END SOFTWARE CHECKS                              #
##################################################################################




# Deprecated CentOS 4 check. Keeping it in case I ever get fed up with fixing
# issues on CentOS 4 boxes because they keep cropping up
##################################################################################
#                                   CENTOS 4 CHECK                               #
##################################################################################

##Check for CentOS 4 since it does not play well with regex in bash
#CENTOS4CHECK=$(cat /etc/redhat-release | awk '{print $3}' | cut -d"." -f1)
#
#if [ "$CENTOS4CHECK" == "4" ]; then
#
#        echo
#
#        echo "!!! CentOS 4 is ${ISSUE}${UNDERLINE}NOT${RESET} supported !!!"
#
#        echo && exit 1
#
#fi


##################################################################################
#                                END CENTOS 4 CHECK                              #
##################################################################################




##################################################################################
#                              BEGIN HEADER FUNCTION                             #
##################################################################################

# The header display function (color version; not sure if I'm going to make a bnw version)
function header_color {

echo
echo " ${ORANGE} ___                           _             "
echo " |_ _|_ __  ___ _ __   ___  ___| |_ ___  _ __           "
echo "  | || '_ \/ __| '_ \ / _ \/ __| __/ _ \| '__|          "
echo "  | || | | \__ \ |_) |  __/ (__| || (_) | |             "
echo " |___|_| |_|___/ .__/ \___|\___|\__\___/|_|${RESET}             "
echo " ${YELLOW}  ____${RESET}        ${ORANGE}|_|${RESET}${YELLOW}_            _       ${RESET} _       "
echo " ${YELLOW} / ___| __ _  __| | __ _  ___| |_     ${RESET}/ \              "
echo " ${YELLOW}| |  _ / _\` |/ _\` |/ _\` |/ _ \ __|    ${RESET}\_/              "
echo " ${YELLOW}| |_| | (_| | (_| | (_| |  __/ |_    ${RESET} /                "
echo " ${YELLOW} \____|\__,_|\__,_|\__, |\___|\__| ${RESET}  / $SCRIPTVERSION           "
echo " ${YELLOW}                   |___/ ${RESET}      "

}



##################################################################################
#                               END HEADER FUNCTION                              #
##################################################################################




##################################################################################
#                           BEGIN SYSTEM INFO FUNCTION                           #
##################################################################################



# Function for all System Info related information
function systeminfo {


# This is currently deprecated. Leaving for historical purposes
## Capture the relevant information for the CPUs on the system
#CPUINFO=$(cat /proc/cpuinfo)

# Identify the specific processor model
PROCESSORTYPE=$(awk -F":" ' {gsub(/^[ \t]+|[ \t]+$/, "", $2)} /model name/ {print $2;exit;}' /proc/cpuinfo)

# This is currently deprecated. Leaving for historical purposes
## Count how many cores are on the system
#PROCESSORCOUNT=$(awk '$1 ~ /processor/ {++c} END {print c}' FS=: <<< $CPUINFO)
PROCESSORCOUNT=$(getconf _NPROCESSORS_ONLN)

# Record the current 1 min load average
LOADAVERAGE=$(cat /proc/loadavg | awk '{print $1}')

echo

echo "------------\\${SYSTEMINFO} ${UNDERLINE}SYSTEM INFO${RESET} \\-------------------------------"

echo

echo "${SYSTEMINFO}System Processor:${RESET} $PROCESSORTYPE"

echo "${SYSTEMINFO}Total # of Cores:${RESET} $PROCESSORCOUNT"

echo "${SYSTEMINFO}Current Load Avg:${RESET} $LOADAVERAGE"

# Capturing the OS version strings
CENTOSVERSION=$(cat /etc/redhat-release 2>/dev/null)
UBUNTUVERSION=$(cat /etc/lsb-release 2>/dev/null)


# Centos version number variables. The first line is running the regex against the text string, identifying
# the line has "release" in it, and then grabs the numerical components, separating them into three distinct
# variables: the whole version: #.#, the major and then minor version numbers (BASH_REMATCH[1] - [3] respectively
# and then those numbers are assigned their own variable that can be called / printed to screen. Technically
# this is all one command / execution, for readability sake it's broken across multiple lines.
CENTOSREGEX="^.*release\ (([0-9])\.([0-9])).*$"
#[[ $CENTOSVERSION =~ ^.*release\ (([0-9])\.([0-9])).*$ ]] &&
[[ $CENTOSVERSION =~ $CENTOSREGEX ]] &&
CENTOSENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: xx.xx
CENTOSMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
CENTOSMINORVERSION=${BASH_REMATCH[3]}     # The minor version #: x

## Same as above, only for Cloud Linux
## This could probably be re-worked to fit BOTH CentOS and CloudLinux. Will need to investigate.
#[[ $(< /root/scripts/inspector/parts/oscheck/cloudlinux) =~ CloudLinux.*\ (([0-9])\.([0-9])).*$ ]] &&
#CLOUDENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: xx.xx
#CLOUDMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
#CLOUDMINORVERSION=${BASH_REMATCH[3]}     # The minor version #: x

# Same as above, only for Ubuntu
UBUNTUREGEX="DISTRIB_DESCRIPTION.*\ (([0-9][0-9])\.([0-9][0-9])).*$"
#[[ $UBUNTUVERSION =~ DISTRIB_DESCRIPTION.*\ (([0-9][0-9])\.([0-9][0-9])).*$ ]] &&
[[ $UBUNTUVERSION =~ $UBUNTUREGEX ]] &&
UBUNTUENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: xx.xx
UBUNTUMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
UBUNTUMINORVERSION=${BASH_REMATCH[3]}     # The minor version #: x


# Checking to see if the variable $CENTOSVERSION is empty or not. If it IS empty we proceed to believe we're on Ubuntu
if [[ -z $CENTOSVERSION ]]; then

        echo "${SYSTEMINFO}Operating System:${RESET} Ubuntu $UBUNTUENTIREVERSION"

# If it's NOT empty, we examine the contents of the varible for the string "CloudLinux". If present, we presume we're on CL, if not, continue
elif [[ $CENTOSVERSION == *CloudLinux* ]]; then

        echo "${SYSTEMINFO}Operating System:${RESET} CloudLinux $CENTOSENTIREVERSION"

# All else fails, we presume we're on a base CentOS install and display accordingly
else

        echo "${SYSTEMINFO}Operating System:${RESET} CentOS $CENTOSENTIREVERSION"

fi

}


##################################################################################
#                           END SYSTEN INFO FUNCTION                             #
##################################################################################




##################################################################################
#                           BEGIN MEMORY INFO FUNCTION                           #
##################################################################################


# Function for all Memory related information
function memoryinfo {

# This captures that information we'll use to display the total GB of memory on the system
MEMINFOGB=$(free -g)

# This captures the rest of the memory related information we'll pull from
MEMINFOMB=$(cat /proc/meminfo)

# This captures the total # of GBs on a system
TOTALMEMMB=$(awk '/Mem:/ {print $2}' <<< "$MEMINFOGB")

# Adds +1 since the actual value displayed does not round up. I'm basically doing the rounding for it
TOTALMEMGB=$(($TOTALMEMMB+1))

# The following capture the total amount of memory, the fre amount and calculates the amount used, all in MB
MEMTOTAL=$(awk -F":" '/MemTotal/{ printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
MEMFREE=$(awk -F":" '/MemFree/{ printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
MEMUSED=$(($MEMTOTAL-$MEMFREE))

# In order to get an accurate value of how much memory is actually free we need to know how much is being used for buffers / cache
BUFFERS=$(awk -F":" '/Buffers/{ printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
CACHED=$(awk -F":" '/Cached/{ printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
BUFFERCACHETOTAL=$(($BUFFERS+$CACHED))

# Determine the actual amount of free memory (since buffer / cache usage gives way to application usage when requested)
MEMTRUEFREE=$(($MEMFREE+$BUFFERCACHETOTAL))

# Calculates the total, free, and actually used swap values
SWAPTOTAL=$(awk -F":" '/SwapTotal/{ printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
SWAPFREE=$(awk -F":" '/SwapFree/ { printf "%.0f", $2/1024 ; exit}' <<< "$MEMINFOMB")
SWAPUSED=$(($SWAPTOTAL-$SWAPFREE))


echo

echo "------------\\${MEMORYINFO} ${UNDERLINE}MEMORY INFO${RESET} \\-------------------------------"

echo

echo "${MEMORYINFO}System Total:${RESET} $TOTALMEMGB G"

echo "${MEMORYINFO}Current Used:${RESET} $MEMUSED M"

echo "${MEMORYINFO}Current Free:${RESET} $MEMTRUEFREE M"

echo "${MEMORYINFO}Current Swap:${RESET} $SWAPUSED M"

}

##################################################################################
#                           END MEMORY INFO FUNCTION                             #
##################################################################################




##################################################################################
#                           BEGIN MYSQL INFO FUNCTION                            #
##################################################################################

# Function for all MySQL related information
function mysqlinfo {

echo

echo "------------\\${MYSQLINFO} ${UNDERLINE}MYSQL INFO${RESET} \\--------------------------------"

echo

# Acquire the MySQL related information that we'll be working with (specifically the version stuff)
MYSQLOUTPUT=$(mysql -V 2>/dev/null)

# Parse the output of $MYSQLOUTPUT and acquire just the version information
MYSQLVERSION=$(awk '{gsub(/,/,""); print $5}'i <<< "$MYSQLOUTPUT")

# Examines the version of MySQL as gathered from the $MYSQLVERSION variable, then captures into individual groups the
# major, minor, and build values. The individual breakdown of the version number is there in case any type of logic
# needs to be used to examine version numbers against one another. More for historical / future uses than anything.

MYSQLREGEX="(([0-9])\.([0-9])\.([0-9][0-9])).*$"
#[[ $MYSQLVERSION =~ (([0-9])\.([0-9])\.([0-9][0-9])).*$ ]] &&
[[ $MYSQLVERSION =~ $MYSQLREGEX ]] &&
MYSQLENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
MYSQLMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
MYSQLMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
MYSQLBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx

# Display the MySQL version (full version number)
echo "${MYSQLINFO}Version In Use:${RESET} $MYSQLENTIREVERSION"

#######################################################

# Display the buffers header / separation:
echo "${MYSQLINFO}${UNDERLINE}BUFFER VALUE(s)${RESET}${MYSQLINFO}  ↓↓↓${RESET}"

# Acquire the contents of the my.cnf file for parsing
MYSQLCONF=$(cat /etc/my.cnf 2>/dev/null)

########## INNODB BUFFER POOL SIZE LOGIC ##############

# Search the $MYSQLCONF variable for the InnoDB Buufer Pool variable. This is just goign to identify if it's there or not
INNODBPRESENT=$(awk '/innodb_buffer_pool_size/' <<< "$MYSQLCONF")

# This will take the value that's assigned to the InnoDB Buffer Pool (should it exist) and store the value
INNODBVALUE=$(awk -F"=" '/innodb_buffer_pool_size/ {print $2}'i <<< "$MYSQLCONF")

# Grabs just the value for the buffer pool
INNODBVALNUMREGEX="(([0-9]+)).*$"
#[[ $INNODBVALUE =~ (([0-9]+)).*$ ]] &&
[[ $INNODBVALUE =~ $INNODBVALNUMREGEX ]] &&
INNODBNUMVALUE=${BASH_REMATCH[1]} # Only the value

#Grabs just the alpha character denoting the memory denomination
INNODBVALALPHREGEX="([A-Za-z]).*$"
#[[ $INNODBVALUE =~ ([A-Za-z]).*$ ]] &&
[[ $INNODBVALUE =~ $INNODBVALALPHREGEX ]] &&
INNODBDENOM=${BASH_REMATCH[1]} # The memory denomination being used

# This calculates what the value would be in MiB since it may be written out in bytes
MYSQLINNODB=$(awk '{size = $1 / 1024 / 1024 ; print size " M"} ' <<< "$INNODBVALUE")

# Examines the my.cnf file, specifically for the InnoDB Buffer Pool Size line. If the line is NOT present it echos the default value
# associated with MySQL, otherwise it reviews to see if the value is set in MiB or bytes. If Bytes it displays the appropriate value
# in MiB through the $MYSQLINNODB variable, if already in MiB it displays that value per the $INNODBVALUE variable

if [[ "$INNODBPRESENT" == "" ]];then

        echo "${MYSQLINFO}Current InnoDB:${RESET} 128 MB (default)"

elif [[ $INNODBVALUE == *M ]] || [[ $INNODBVALUE == *G ]]; then

	echo "${MYSQLINFO}Current InnoDB:${RESET} $INNODBNUMVALUE $INNODBDENOM"

else

        echo "${MYSQLINFO}Current InnoDB:${RESET} $MYSQLINNODB"

fi

########## MYISAM KEY BUFFER SIZE LOGIC ###############

# Search the $MYSQLCONF variable for the InnoDB Buufer Pool variable. This is just goign to identify if it's there or not
MYISAMPRESENT=$(awk '/key_buffer/' <<< "$MYSQLCONF")

# This will take the value that's assigned to the InnoDB Buffer Pool (should it exist) and store the value
MYISAMVALUE=$(awk -F"=" '/key_buffer/ {print $2}'i <<< "$MYSQLCONF")

# Grabs just the value for the buffer pool
MYISAMVALNUMREGEX="(([0-9]+)).*$"
#[[ $MYISAMVALUE =~ (([0-9]+)).*$ ]] &&
[[ $MYISAMVALUE =~ $MYISAMVALNUMREGEX ]] &&
MYISAMNUMVALUE=${BASH_REMATCH[1]} # Only the value

#Grabs just the alpha character denoting the memory denomination
MYISAMVALALPHREGEX="([A-Za-z]).*$"
#[[ $MYISAMVALUE =~ ([A-Za-z]).*$ ]] &&
[[ $MYISAMVALUE =~ $MYISAMVALALPHREGEX ]] &&
MYISAMDENOM=${BASH_REMATCH[1]} # The memory denomination being used

# This calculates what the value would be in MiB since it may be written out in bytes
MYSQLMYISAM=$(awk '{size = $1 / 1024 / 1024 ; print size " M"} ' <<< "$MYISAMVALUE")


# Examines the my.cnf file, specifically for the Key Buffer Pool Size line. If the line is NOT present it echos the default value
# associated with MySQL, otherwise it reviews to see if the value is set in MiB or bytes. If Bytes it displays the appropriate value
# in MiB through the $MYSQLMYISAM variable, if already in MiB it displays that value per the $MYISAMVALUE variable

if [[ "$MYISAMPRESENT" == "" ]];then

        echo "${MYSQLINFO}Current MyISAM:${RESET} 8 M (default)"

elif [[ $MYISAMVALUE == *M ]] || [[ $MYISAMVALUE == *G ]];then

        echo "${MYSQLINFO}Current MyISAM:${RESET} $MYISAMNUMVALUE $MYISAMDENOM"

else

        echo "${MYSQLINFO}Current MyISAM:${RESET} $MYSQLMYISAM"

fi

}

##################################################################################
#                           END MYSQL INFO FUNCTION                              #
##################################################################################




##################################################################################
#                           BEGIN  PHP INFO FUNCTION                             #
##################################################################################

# Function for all PHP Info related information
function phpinfo {

# Capture the output of the command php -v for later use
PHPVOUTPUT=$(php -v 2>/dev/null)

# Capture the memory_limit line from the global php.ini
#PHPGLOBALCONF=$(awk -F"=" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /memory_limit/ {print $2}' /usr/local/lib/php.ini)
PHPGLOBALCONF=$(awk -F"=" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /memory_limit/ {print $2}' $ACTUALPHPINI)


echo "------------\\${PHPINFO} ${UNDERLINE}PHP INFO${RESET} \\----------------------------------"

echo


## Grab the version of PHP currently installed on the system
PHPREGEX="(([0-9])\.([0-9]+)\.([0-9]+)).*$"
#[[ $PHPVOUTPUT =~ (([0-9])\.([0-9]+)\.([0-9]+)).*$ ]] &&
[[ $PHPVOUTPUT =~ $PHPREGEX ]] &&
PHPENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
PHPMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
PHPMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
PHPBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx

# Display the PHP version
echo "${PHPINFO}Version In Use:${RESET} $PHPENTIREVERSION"

# Quick check against a file that will verify if cPanel IS or is NOT installed. This is stored in a variable
CPANELTEST=$(cat /usr/local/cpanel/version 2>/dev/null)

# Check against that variable. If cPanel IS installed, grab the various PHP handlers from the location cPanel sets
if [[ ! -z "$CPANELTEST" ]]; then

PHPCONF=$(cat /usr/local/apache/conf/php.conf 2>/dev/null)

CGIHANDLER=$(awk 'match($0,/cgi-sys/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
SUPHPHANDLER=$(awk 'match($0,/suphp/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
DSOHANDLER=$(awk 'match($0,/libphp5/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
FCGIHANDLER=$(awk 'match($0,/fcgid/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")


if [[ ! -z "$FCGIHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} fCGI"

elif [[ ! -z "$SUPHPHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} SuPHP"

elif [[ ! -z "$DSOHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} DSO"

elif [[ ! -z "$CGIHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} CGI"

fi


# If cPanel is NOT installed, grab the handlers from the default location Apache sets / uses
else

PHPCONF=$(cat /etc/httpd/conf.d/php.conf 2>/dev/null)

CGIHANDLER=$(awk 'match($0,/cgi-sys/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
SUPHPHANDLER=$(awk 'match($0,/suphp/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
DSOHANDLER=$(awk 'match($0,/libphp5/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")
FCGIHANDLER=$(awk 'match($0,/fcgid/) {print substr($0,RSTART,RLENGTH)}' <<< "$PHPCONF")

if [[ ! -z "$FCGIHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} fCGI"

elif [[ ! -z "$SUPHPHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} SuPHP"

elif [[ ! -z "$DSOHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} DSO"

elif [[ ! -z "$CGIHANDLER" ]]; then

echo "${PHPINFO}Handler In Use:${RESET} CGI"

fi

fi


# Grabs just the value for the memory_limit
PHPCONFVALREGEX="(([0-9][0-9])).*$"
#[[ $PHPGLOBALCONF =~ (([0-9][0-9])).*$ ]] &&
[[ $PHPGLOBALCONF =~ $PHPCONFVALREGEX ]] &&
PHPMEMLIMIT=${BASH_REMATCH[1]} # Only the value for the PHP memory_limit

PHPCONFALPHREGEX="([A-Za-z]).*$"
#[[ $PHPGLOBALCONF =~ ([A-Za-z]).*$ ]] &&
[[ $PHPGLOBALCONF =~ $PHPCONFALPHREGEX ]] &&
PHPMEMLIMITDENOM=${BASH_REMATCH[1]} # The memory denomination being used

# ************************************************************************************************************
# **NOTE** this does NOT (yet) know if the memory limit is using M or G. Thus if a client has a memory_limit
# of 1 G this will display "1 MB". Logic to correctly determine that is forthcoming / needs to be written
# ************************************************************************************************************

# Display the PHP memory_limit value
echo "${PHPINFO}Memory Limit #:${RESET} $PHPMEMLIMIT $PHPMEMLIMITDENOM"

}

##################################################################################
#                            END PHP INFO FUNCTION                               #
##################################################################################




##################################################################################
#                           BEGIN APACHE INFO FUNCTION                           #
##################################################################################


# Function for all Apache Info related information
function apacheinfo {

# Grabs / stores the contents of the http -V command for later parsing
APACHEFULLINFO=$(httpd -V)

# Grabs the netstat info for later parsing to find the number of active connections
NETSTATINFO=$(netstat -nap 2>/dev/null)

# Not including this under Apache. Will examine adding it to a "Traffic" section later on
## Parses the netstat info and provides us with only the number of TCP connections
#NUMOFCONNS=$(awk '/:80/ {++c} END {print c}' <<< "$NETSTATINFO")

# Get the entire Apache version number from the string in the $APACHEINFO variable
APACHEVERSION=$(awk -F[/\ ] '/Server version/ {print $4}'i <<< $APACHEFULLINFO)

# Get the currently used MPM
APACHEMPM=$(awk -F[:] '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Server MPM/ {print $2}'x <<< "$APACHEFULLINFO")


# This parses the Apache version and breaks it down into the individual components of the version number with each part
# being stored as a separate variable. These individual components are not being utilized but provide the ability to
# easily compare the major / minor version numbers for version checking.
#[[ $APACHEVERSION =~ (([0-9])\.([0-9])\.([0-9][0-9])).*$ ]] &&
APACHEREGEX="(([0-9])\.([0-9])\.([0-9]+)).*$"
#[[ $APACHEVERSION =~ (([0-9])\.([0-9])\.([0-9]+)).*$ ]] &&
[[ $APACHEVERSION =~ $APACHEREGEX ]] &&
APACHEENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
APACHEMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
APACHEMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
APACHEBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx


echo

echo "------------\\${APACHEINFO} ${UNDERLINE}APACHE INFO${RESET} \\-------------------------------"

echo

echo "${APACHEINFO}Version In Use:${RESET} $APACHEENTIREVERSION"

echo "${APACHEINFO}MPM Being Used:${RESET} $APACHEMPM"

#echo "${APACHEINFO}Connections In:${RESET} $NUMOFCONNS"

}

##################################################################################
#                            END APACHE INFO FUNCTION                            #
##################################################################################




##################################################################################
#                            BEGIN CPANEL INFO FUNCTION                          #
##################################################################################

# Function for all cPanel Info related information
function cpanelinfo {

# Grab the cPanel version number
CPANELVERSION=$(</usr/local/cpanel/version)

# Inspects the cPanel release tier
CPANELRELEASE=$(awk -F"=" ' /CPANEL/ {print $2}' /etc/cpupdate.conf)

## Determines if legacy cPanel backups are enabled
#CPANELLEGACY=$(awk -F" " ' /BACKUPENABLE/ {print $2}' /etc/cpbackup.conf)
#
## Determines if the new cPanel backups are enabled
#CPANELBACKUP=$(awk -F" " ' {gsub(/^[ \t]+|[ \t]+$/, "", $2)} /BACKUPENABLE/ {gsub( "['\'']","" ); print $2}' /var/cpanel/backups/config)

# This parses the cPanel version and breaks it down into the individual components of the version number with each part
# being stored as a separate variable. These individual components are not being utilized but provide the ability to
# easily compare the major / minor version numbers for version checking.
CPANELREGEX="(([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)).*$"
#[[ $CPANELVERSION =~ (([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)).*$ ]] &&
[[ $CPANELVERSION =~ $CPANELREGEX ]] &&
CPANELENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: xx.xx.x.xx
CPANELMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: xx
CPANELMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: xx
CPANELBUILDVERSION=${BASH_REMATCH[4]} &&  # The build version #: x
CPANELREVISIONVERSION=${BASH_REMATCH[5]}   # The revision version #: xx


# Because older versions of cPanel set the backup status in a different file
if [[ "$CPANELMINORVERSION" -le "32" ]]; then

        CPANELLEGACY=$(awk -F" " ' /BACKUPACCTS/ {print $2}' /etc/cpbackup.conf)

else

# Determines if legacy cPanel backups are enabled
        CPANELLEGACY=$(awk -F" " ' /BACKUPENABLE/ {print $2}' /etc/cpbackup.conf)

fi

# Determines if the new cPanel backups are enabled
CPANELBACKUP=$(awk -F" " ' {gsub(/^[ \t]+|[ \t]+$/, "", $2)} /BACKUPENABLE/ {gsub( "['\'']","" ); print $2}' /var/cpanel/backups/config 2>/dev/null)




echo

echo "------------\\${CPANELINFO} ${UNDERLINE}CPANEL INFO${RESET} \\-------------------------------"

echo

echo "${CPANELINFO}Version In Use:${RESET} $CPANELVERSION"

echo "${CPANELINFO}Release Set To:${RESET} $CPANELRELEASE"

# Logic to review the status of the different backups systems to depending on if they're enabled or disabled
# display an appropriate message

if [ "$CPANELMINORVERSION" == "32" ] && [ "$CPANELLEGACY" == "yes" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Enabled"

elif [ "$CPANELMINORVERSION" == "32" ] && [ "$CPANELLEGACY" == "no" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Disabled"

else

if [ "$CPANELLEGACY" == "no" ] && [ "$CPANELBACKUP" == "no" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Disabled"

elif [ "$CPANELLEGACY" == "no" ] && [ "$CPANELBACKUP" == "yes" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Enabled"

elif [ "$CPANELLEGACY" == "yes" ] && [ "$CPANELBACKUP" == "no" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Legacy Enabled"

elif [ "$CPANELLEGACY" == "yes" ] && [ "$CPANELBACKUP" == "yes" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} BOTH Systems Enabled"

fi
fi

}

##################################################################################
#                            END CPANEL INFO FUNCTION                            #
##################################################################################




##################################################################################
#                         BEGIN RAID ARRAY TEST FUNCTION                         #
##################################################################################

# Function for all RAID array tests
function arraytest {

# Logic to examine if the current array is on an LSI controller, if so it proceeds
if [[ "$RAIDBRAND" == "LSI" ]];then

	# Counts the number of arrays on the controller and assigns to variable
	#NUMARRAYS=$(/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -L"$lsicontroller" -aAll | awk '/Virtual Drive/ { count++ } END { print count }')
	NUMARRAYS=$(/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -a"$lsicontroller" | awk '/Virtual Drive/ { count++ } END { print count }')

	# Because arrays start at 0, we subtract 1 from the # of arrays and create a counter for our iterations
	ARRAYITERATIONS=$(echo "$NUMARRAYS-1" | bc)

	# Also want to know how what array we're looking at if there are multiple, created empty counter for this
	CURRENTARRAY=0

	# For loop that runs through the arrays, increasing the iteration counter each time, and gathers the various
	# pieces of information relating to each array and displaying it accordingly.
	for (( array=0; array<=$ARRAYITERATIONS; array++ )); do

		# Gathers the general information about each array and stores it in a variable. We'll use this repeatedly
		#ARRAYINFO=$(/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -L"$lsicontroller" -a"$CURRENTARRAY")
		ARRAYINFO=$(/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -L"$CURRENTARRAY" -a"$lsicontroller")

		# Determines the number of disks on a span, and the number of spans for an array. We'll use this to calculate the
		# RAID level that array is setup for in a moment
		LSIDISKS=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Number Of Drives/ {print $2}' <<< "$ARRAYINFO")
		LSISPANS=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Span/ {print $2}' <<< "$ARRAYINFO")

		# Calculates the total number of disks that comprise the array
		LSINUMBERDISKS=$((LSIDISKS * LSISPANS))

		# Grabs the "Primary" RAID level. Based on the number of disks / spans we can get the actual RAID level
		LSIRAIDPRIMARY=$(awk -F"-" '/Primary/ {gsub(/,.*/,""); print $2}' <<< "$ARRAYINFO")

		# Let us know what array this information applies to. This is NOT the logical array position.
		echo "${DISKINFO}RAID Array:${RESET} #$CURRENTARRAY"

		# Displays the number of disks, spans, and the actual RAID level
		echo "${DISKINFO}# of Disks:${RESET}" $LSINUMBERDISKS

		if [[ "$LSIRAIDPRIMARY" == "1" && "$LSISPANS" -gt "1" ]]; then

        		echo "${DISKINFO}RAID Level:${RESET} 10"

		elif [[ "$LSISPANS" == "1" ]];then

        		echo "${DISKINFO}RAID Level:${RESET} 1"

		else

        		echo "${DISKINFO}Raid Level:${RESET} $LSIRAIDPRIMARY"

		fi

		echo

		# Increases the counter for what array we just examined
		((CURRENTARRAY+=1))
	done

# Logic to examine if the current array is on an Adaptec controller, if so it proceeds
elif [[ "$RAIDBRAND" == "Adaptec" ]];then

	# Counts the number of arrays on the controller and assigns to variable
	NUMARRAYS=$(/usr/StorMan/arcconf getconfig $controller ld | awk '/Logical device number/ { count++ } END { print count }')

	# Because arrays start at 0, we subtract 1 from the # of arrays and create a counter for our iterations
        ARRAYITERATIONS=$(echo "$NUMARRAYS-1" | bc)

        # Also want to know how what array we're looking at if there are multiple, created empty counter for this
        CURRENTARRAY=0

        # For loop that runs through the arrays, increasing the iteration counter each time, and gathers the various
        # pieces of information relating to each array and displaying it accordingly.
        for (( array=0; array<=$ARRAYITERATIONS; array++ )); do

                # Gathers the general information about each array and stores it in a variable. We'll use this repeatedly
                #ARRAYINFO=$(/usr/StorMan/arcconf getconfig "$adapteccontroller" ld "$CURRENTARRAY")
                ARRAYINFO=$(/usr/StorMan/arcconf getconfig "$controller" ld "$CURRENTARRAY")

		# Counter the number of disks involved and the RAID level of the array
		#ADAPTECDISKS=$(awk '/Device #/ {++c} END {print c}' <<< "$ARRAYINFO")
		ADAPTECDISKS=$(awk '/Segment [0-9]/ {++c} END {print c}' <<< "$ARRAYINFO")
		ADAPTECRAID=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /RAID level/ {print $2}' <<< "$ARRAYINFO")

		# Let us know what array this information applies to. This is NOT the logical array position.
		echo "${DISKINFO}RAID Array:${RESET} #$CURRENTARRAY"

		# Displays the number of disks involved in the array and the RAID level
		echo "${DISKINFO}# of Disks:${RESET}" $ADAPTECDISKS

        	echo "${DISKINFO}RAID Level:${RESET}" $ADAPTECRAID

		echo

		# Increases the counter for what array we just examined
		((CURRENTARRAY+=1))

	done

fi
}

##################################################################################
#                           END RAID ARRAY TEST FUNCTION                         #
##################################################################################




##################################################################################
#                            BEGIN DISK INFO FUNCTION                            #
##################################################################################

# Function for all Disk Info related information
function diskinfo {

# Identify the BRAND of the RAID controller currently being used
RAIDBRAND=$(lspci 2>/dev/null | awk '/Adaptec|LSI/{for(i=1;i<=NF;++i)if($i~/Adaptec|LSI/)print $i}')

# Controller counters. Identifies the physical controller being queries, and sets the counters for the
# brand specific versioning of what controller is being queried
controller=1
adapteccontroller=1
lsicontroller=0

ADAPTERS=$RAIDBRAND
CARDARRAY=( ${ADAPTERS} )
NUMCARDS=$(echo ${#CARDARRAY[@]})


## I'm sure this could be better accomplished with some regex and more of it handled within Bash itself. For now this works
## and is extremely fast (not to mention it formats how I want). It stays. Will likely be reviewed at a later date.
#DISKUSAGE=$(paste <(df -h | awk '{ $6=""; $7=""; print }' | column -t) <(df -hi | awk '{print substr($0, index($0, $5))}' | column -t))

echo

echo "------------\\${DISKINFO} ${UNDERLINE}DISK INFO${RESET} \\---------------------------------"

echo

echo "${DISKINFO}Disk Usage:${RESET}"

# I'm not concerned with showing all the SAN mounts. This examines the fstab file and uses the SAN mount entries there as a list
# for what to remove from the actual disk usage display
if grep -q \#zbind "/etc/fstab"; then

# Some gnarly uses of the paste and column commands that allow me to interject the inode usage % inline with the disk usage display
	paste <(df -h | grep -v "$(awk '/\#zbind/ {print $1}' /etc/fstab)" | grep -v '^ ' | awk '{ $6=""; $7=""; print }' | column -t) <(df -hi | sed 's/on//' | grep -v "$(awk '/\#zbind/ {print $1}' /etc/fstab)" | grep -v '^ ' | awk '{print substr($0, index($0, $5))}' | column -t)

else

	paste <(df -h | awk '{ $6=""; $7=""; print }' | column -t) <(df -hi | sed 's/on//' | awk '{print substr($0, index($0, $5))}' | column -t)

fi

echo


# If there is no RAID card installed present "N/A" to indicate no RAID setup
if [[ "$RAIDBRAND" == "" ]];then

	echo "${DISKINFO}Controller:${RESET} N/A"

# Examines how many RAID controller cards are installed on the system. If equal to one, only examines
# the number of arrays involved with that controller. If more than one card exists it examines their
# brand to see how many iterations of the arraytest function it needs to perform for each controller
elif [[ "$NUMCARDS" == "1" ]];then
RAIDBRAND=${CARDARRAY[$I]}
  if [[ "$RAIDBRAND" == "Adaptec" ]]; then

     ADAPTECMODEL=$(/usr/StorMan/arcconf getconfig "$adapteccontroller" | awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Controller Model/ {print $2}')

     echo "${DISKINFO}Model Used:${RESET} $ADAPTECMODEL"

     echo

  elif [[ "$RAIDBRAND" == "LSI" ]]; then

     LSIMODEL=$(/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -a"$lsicontroller" | awk -F ":" '/Product Name/ {print $2}' | sed -e 's/^[ \t]*//')

     echo "${DISKINFO}Model Used:${RESET} $LSIMODEL"

     echo

  fi
  arraytest
  echo

elif [[ "$NUMCARDS" -gt "1" ]]; then


# For loop that identifies if the first controller is an Adaptec or LSI controller, then proceeds with the
# logic to grab the model before calling the arraytest function to examine for multiple RAID arrays
# on the particular controller. Finally it increments the various counter variables to examine if there are
# any additional controllers to be examined
for I in ${!CARDARRAY[*]}; do
  RAIDBRAND=${CARDARRAY[$I]}
  #echo "${DISKINFO}Controller:${RESET} #$controller"

  if [[ "$RAIDBRAND" == "Adaptec" ]]; then

     ADAPTECMODEL=$(/usr/StorMan/arcconf getconfig "$adapteccontroller" | awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Controller Model/ {print $2}')

     echo "${DISKINFO}Controller:${RESET} #$controller"
     echo "${DISKINFO}Model Used:${RESET} $ADAPTECMODEL"

     ((adapteccontroller+=1))

     echo

  elif [[ "$RAIDBRAND" == "LSI" ]]; then

     LSIMODEL=$(/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -a"$lsicontroller" | awk -F ":" '/Product Name/ {print $2}' | sed -e 's/^[ \t]*//')

     echo "${DISKINFO}Controller:${RESET} #$lsicontroller"
     echo "${DISKINFO}Model Used:${RESET} $LSIMODEL"

     #((lsicontroller+=1))

     echo

  fi

  arraytest

  ((controller+=1))
  ((lsicontroller+=1))

done

fi

}

##################################################################################
#                             END DISK INFO FUNCTION                             #
##################################################################################




##################################################################################
#                            BEGIN NGINX INFO FUNCTION                           #
##################################################################################

# Start the nginxinfo function
function nginxinfo {

if [[ ! -x /usr/sbin/nginx ]]; then

echo

else

# Tests to see if Nginx is present and if so records the version string
NGINXVOUTPUT=$(nginx -v 2>&1)

## Grab the version of Nginx currently installed on the system
NGINXREGEX="(([0-9])\.([0-9]+)\.([0-9]+)).*$"
[[ $NGINXVOUTPUT =~ $NGINXREGEX ]] &&
NGINXENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
NGINXMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
NGINXMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
NGINXBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx


# If the Nginx version can be found, continue, otherwise do nothing
if [[ ! -z "$NGINXVOUTPUT" ]]; then

	echo

	echo "------------\\${NGINXINFO} ${UNDERLINE}NGINX INFO${RESET} \\----------------------------------"

	echo


	echo "${NGINXINFO}Version In Use:${RESET} ${NGINXENTIREVERSION}"


fi

fi
}

##################################################################################
#                              END NGINX INFO FUNCTION                           #
##################################################################################




##################################################################################
#                            BEGIN VARNISH INFO FUNCTION                         #
##################################################################################

# Start varnishinfo function
function varnishinfo {

# Tests to see if Varnish is present and if so records the version string
VARNISHVOUTPUT=$(/opt/varnish/sbin/varnishd -V 2>/dev/null)

## Grab the version of Varnish currently installed on the system
VARNISHREGEX="(([0-9])\.([0-9]+)\.([0-9]+)).*$"
[[ $VARNISHVOUTPUT =~ $VARNISHREGEX ]] &&
VARNISHENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
VARNISHMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
VARNISHMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
VARNISHBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx


# If the output of the Varnish version is present, display. Otherwise do nothing
if [[ ! -z "$VARNISHVOUTPUT" ]]; then


echo

echo "------------\\${VARNISHINFO} ${UNDERLINE}VARNISH INFO${RESET} \\----------------------------------"

echo

echo "${VARNISHINFO}Version In Use:${RESET} ${VARNISHENTIREVERSION}"

fi

}

##################################################################################
#                              END VARNISH INFO FUNCTION                         #
##################################################################################




##################################################################################
#                           BEGIN PRIMARY LOGIC FUNCTION                         #
##################################################################################

# Begin function primary_logic
function primary_logic {


# If no command line argument given, run all functions
if [[ -z $1 ]]; then


# If cPanel IS installed, run all the functions. If it's NOT installed, only run non-cPanel safe functions
if [[ ! -z "$CPANELTEST" ]]; then
systeminfo
memoryinfo
diskinfo
apacheinfo
nginxinfo
varnishinfo
phpinfo
cpanelinfo
mysqlinfo

# If cPanel is NOT installed, check to see if  Apache, PHP, and MySQL ARE installed. If so, run Apache / PHP / MySQL safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]] && [[ ! -z "$MYSQLTEST" ]]; then
systeminfo
memoryinfo
diskinfo
apacheinfo
nginxinfo
varnishinfo
phpinfo
mysqlinfo

# If Apache and MySQL are NOT BOTH installed, check to see if Apache and PHP are installed. If they are, run Apache / PHP safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]]; then
systeminfo
memoryinfo
diskinfo
apacheinfo
nginxinfo
varnishinfo
phpinfo

# If Apache and PHP are NOT BOTH installed, check to see if JUST Apache is installed. If it is, run Apache safe functions
#elif [[ ! -z "$APACHETEST" ]] && [[ -z "$MYSQLTEST" ]]; then
elif [[ ! -z "$APACHETEST" ]]; then
systeminfo
memoryinfo
diskinfo
apacheinfo
nginxinfo
varnishinfo

# If Apache and MySQL are not BOTH installed, and Apache is not installed, check for MySQL. If it is installed, run MySQL safe functions
#elif [[ ! -z "$MYSQLTEST" ]] && [[ -z "$APACHETEST" ]]; then
elif [[ ! -z "$MYSQLTEST" ]]; then
systeminfo
memoryinfo
diskinfo
nginxinfo
varnishinfo
mysqlinfo

else

# If cPanel, Apache, and MySQL are NOT installed, run basic functions
systeminfo
memoryinfo
diskinfo
nginxinfo
varnishinfo

fi

fi

}

##################################################################################
#                            END PRIMARY LOGIC FUNCTION                          #
##################################################################################






##################################################################################
#                         BEGIN SOFTWARE ONLY LOGIC FUNCTION                     #
##################################################################################

# Begin the function that will only display software related information. The follow examines the various functions themselves
# and the logic decides if the function should be run based on the software being installed
function soft {

# Check against that variable. If cPanel IS installed, run all the functions. If it's NOT installed, only run non-cPanel safe functions
if [[ ! -z "$CPANELTEST" ]]; then
apacheinfo
nginxinfo
varnishinfo
phpinfo
cpanelinfo
mysqlinfo

# If cPanel is NOT installed, check to see if  Apache, PHP, and MySQL ARE installed. If so, run Apache / PHP / MySQL safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]] && [[ ! -z "$MYSQLTEST" ]]; then
apacheinfo
nginxinfo
varnishinfo
phpinfo
mysqlinfo

# If Apache and MySQL are NOT BOTH installed, check to see if Apache and PHP are installed. If they are, run Apache / PHP safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]]; then
apacheinfo
nginxinfo
varnishinfo
phpinfo

# If Apache and PHP are NOT BOTH installed, check to see if just Apache and MySQL are installed. If they are, run Apache / MySQL safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$MYSQLTEST" ]]; then
apacheinfo
nginxinfo
varnishinfo
mysqlinfo

# If Apache and PHP are NOT BOTH installed, check to see if JUST Apache is installed. If it is, run Apache safe functions
#elif [[ ! -z "$APACHETEST" ]] && [[ -z "$MYSQLTEST" ]]; then
elif [[ ! -z "$APACHETEST" ]]; then
apacheinfo
nginxinfo
varnishinfo

# If Apache and MySQL are not BOTH installed, and Apache is not installed, check for MySQL. If it is installed, run MySQL safe functions
#elif [[ ! -z "$MYSQLTEST" ]] && [[ -z "$APACHETEST" ]]; then
elif [[ ! -z "$MYSQLTEST" ]]; then
mysqlinfo
nginxinfo
varnishinfo

else

echo
echo
# If no software is present on the server that Inspector Gadget can "inspect", display an error
echo "   ${ISSUE}!!!${RESET} ${UNDERLINE}No compatiable software to inspect${RESET} ${ISSUE}!!!${RESET}"
fi
}

##################################################################################
#                           END SOFTWARE ONLY LOGIC FUNCTION                     #
##################################################################################




##################################################################################
#                            BEGIN TRAFFIC INFO FUNCTION                         #
##################################################################################

# Begin trafficinfo function
function trafficinfo {

# Grab the current date. We'll use this to examine the logs for today's entries only
NOW=$(date +"%d/%b/%Y")

# Using the current date, store all the entries from all domlogs into a variable that we can reference
# repeatedly without having to call upon that data over and over again
DOMLOGINFO=$(grep "$NOW:" /home/domlogs/*)

# Variable storing the output of the netstat command so that I could use the same information across
# multiple aspects of this script without having to call netstat each time
NETSTATINFO=$(netstat -nap)

# Funnel the domlog data into an awk statement that will search for only entries that are a POST requests
# and then pipes that into an array. Each unique entry (see: domain) gets it's own line. Any duplicate entries
# (meaning domains receiving multiple POST requests) will be tallied up and a number displayed next to them
DOMAINREQS=$(awk -F":" '/POST/ {h[$1]++}; END { for(k in h) print k, h[k] }' <<< "$DOMLOGINFO" | sort -n)

# Funnel the domlog data into an awk statement that will search for only entries that are a POST requests
# and then pipes that into an array. Each unique entry (see: IP address) gets it's own line. Any duplicate entries
# (meaning IPs sending multiple POST requests) will be tallied up and a number displayed next to them
IPREQS=$(awk -F '[: ]' '/POST/ {h[$2]++}; END { for(k in h) print k, h[k] }' <<< "$DOMLOGINFO" | column -t)

# Funnel the domlog data into an awk statement that will search for only entries that are a POST requests
# and then pipes that into an array. Each unique entry (see: file) gets it's own line. Any duplicate entries
# (meaning files receiving multiple POST requests) will be tallied up and a number displayed next to them
FILEREQS=$(awk '/POST/ {h[$7]++}; END { for(k in h) print k, h[k] }' <<< "$DOMLOGINFO" | column -t | head -n5)

# Couple of awk statements that parse through the netstat info and gathers the current IP addresses with
# connections and how many connections each has
TOPIPCONNS=$(awk '/:80/ {print $5}' <<< "$NETSTATINFO" | awk -F":" '{h[$1]++}; END { for(k in h) print k, h[k] }')

# Uses the netstatinfo variable to identify the total number of connections currently on port 80
ACTIVECONNS=$(grep :80 <<< "$NETSTATINFO" | wc -l)

# Uses the output of the $DOMAINREQS variable to identify the website that had the most posts requests
HITTER=$(awk 'NR==1{print $1}' <<< "$DOMAINREQS" | cut -d "/" -f4)

DOMAINFILES=$(grep "$NOW:" /home/domlogs/$HITTER | awk '/POST/ {h[$7]++}; END { for(k in h) print k, h[k] }' | column -t | head -n5)


echo

echo "-----------\ ${TRAFFICINFO}${UNDERLINE}TRAFFIC INFO${RESET} \-------------------------------"

echo

echo "${TRAFFICINFO}# of connections active now on port 80:${RESET} $ACTIVECONNS"

echo

echo "${TRAFFICINFO}Top IPs and # of connections each made:${RESET}"

awk '{print $2,$1}' <<< "$TOPIPCONNS" | column -t

echo

echo "${TRAFFICINFO}# of connections domains are receiving:${RESET}"

awk '{print $2 "  " $1}' <<< "$DOMAINREQS"

echo

echo "${TRAFFICINFO}Connections and IPs with POST requests:${RESET}"

awk '{print $2 "  " $1}' <<< "$IPREQS"

echo

echo "${TRAFFICINFO}Files receiving the most POST requests:${RESET}"

awk '{print $2 "  " $1}' <<< "$FILEREQS"

echo

echo "${TRAFFICINFO}Files with most POST requests on $HITTER${RESET}"

awk '{print $2 "  " $1}' <<< "$DOMAINFILES"

echo
}

##################################################################################
#                            END TRAFFIC INFO FUNCTION                           #
##################################################################################




##################################################################################
#                            BEGIN HELP OPTION FUNCTION                          #
##################################################################################

function HELP {
  echo -e \\n"Help documentation for Inspector Gadget."\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "-nh | --no-header --Removes the header function so it is no longer displayed."
  echo "-a  | --all     --Runs all functions. This is the default behavior."
  echo "-s  | --system  --Runs hardware related functions ONLY."
  echo "-c  | --core    --Runs software related functions ONLY. "
  echo -e "-h  | --help    --Displays this help message. No further functions are performed."\\n
  echo -e "Example: ./inspector.sh -c"\\n
  echo -e "Example: bash <(curl -skL inspector.sh) -c"\\n
  exit 1
}

##################################################################################
#                              END HELP OPTION FUNCTION                          #
##################################################################################





# Before doing anything, clear the screen
clear




##################################################################################
#                               BEGIN CASE STATEMENTS                            #
##################################################################################

# The case statement that evaluates the options passed to the script. Fairly self-explanatory, but the options each coincide with a
# particular function (or function group) and technically multiple options can be passed at once. If no argument is passed all
# functions run, if an invalid argument is passed an error is displayed.

# If any option to display specific content is chosen / passed, alter this to "true"
optionran="false"

# The casecading case statement. This examines each option passed and will "shift" to look for any additional options passed
# If any specific option is passed it will alter the "optionran" variable to "true", negating the default behavior of the script
# to display the primary_logic function
while [ ! $# -eq 0 ]
do
    case "$1" in
        --help | -h)
	    header_color 2>/dev/null
            HELP
            exit
            ;;
	--no-header | -nh)
	    unset -f header_color
	    ;;
        --all | -a)
	    header_color 2>/dev/null
            primary_logic
	    optionran="true"
	    unset -f header_color
            ;;
        --system | -s)
	    header_color 2>/dev/null
            systeminfo
            memoryinfo
            diskinfo
	    optionran="true"
	    unset -f header_color
            ;;
        --core | -c)
	    header_color 2>/dev/null
            soft
	    optionran="true"
	    unset -f header_color
            ;;
	--traffic | -t)
	    header_color 2>/dev/null
	    trafficinfo
	    optionran="true"
	    unset -f header_color
	    ;;
        *)
	    header_color 2>/dev/null
            echo
            echo "   ${ISSUE}!!!${RESET}   ${UNDERLINE}invalid option${RESET}   ${ISSUE}!!!${RESET}"
            echo
            HELP
    esac
    shift
done

# If the script is executed and no options were passed run the header_color and primary_logic functions. This simulates a
# default behavior for the script
if [ "$optionran" == "false" ]; then
	header_color 2>/dev/null
	primary_logic
fi


##################################################################################
#                                END CASE STATEMENTS                             #
##################################################################################




echo
