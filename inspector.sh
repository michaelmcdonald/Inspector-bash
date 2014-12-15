#!/bin/bash

#   TITLE: Inspector Gadget
#  AUTHOR: michael mcdonald
# CONTACT: michael@liquidweb.com
# VERSION: 1.08
# PURPOSE: to examine various aspects of a Linux system and provide
#          quick access to that information in a clean format

##################################################################################

# Various color variables used throughout the script

HEADERINFO=$(tput setaf 2)
MEMORYINFO=$(tput setaf 180)
SYSTEMINFO=$(tput setaf 124)
DISKINFO=$(tput setaf 100)
TRAFFICINFO=$(tput setaf 210)
CPANELINFO=$(tput setaf 172)
MYSQLINFO=$(tput setaf 24)
APACHEINFO=$(tput setaf 5)
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

ACTUALPHPINI=$(php -i | grep "Loaded Configuration File" 2>/dev/null | awk '{print $5}')


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
echo " ${YELLOW} \____|\__,_|\__,_|\__, |\___|\__| ${RESET}  / v1.08           "
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
PROCESSORTYPE=$(awk -F":" ' {gsub(/^[ \t]+|[ \t]+$/, "", $2)} /model name/ {print $2}' /proc/cpuinfo)

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
[[ $CENTOSVERSION =~ ^.*release\ (([0-9])\.([0-9])).*$ ]] &&
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
[[ $UBUNTUVERSION =~ DISTRIB_DESCRIPTION.*\ (([0-9][0-9])\.([0-9][0-9])).*$ ]] &&
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
MYSQLOUTPUT=$(mysql -V)

# Parse the output of $MYSQLOUTPUT and acquire just the version information
MYSQLVERSION=$(awk '{gsub(/,/,""); print $5}'i <<< "$MYSQLOUTPUT")

# Examines the version of MySQL as gathered from the $MYSQLVERSION variable, then captures into individual groups the
# major, minor, and build values. The individual breakdown of the version number is there in case any type of logic
# needs to be used to examine version numbers against one another. More for historical / future uses than anything.

[[ $MYSQLVERSION =~ (([0-9])\.([0-9])\.([0-9][0-9])).*$ ]] &&
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
MYSQLCONF=$(cat /etc/my.cnf)

########## INNODB BUFFER POOL SIZE LOGIC ##############

# Search the $MYSQLCONF variable for the InnoDB Buufer Pool variable. This is just goign to identify if it's there or not
INNODBPRESENT=$(awk '/innodb_buffer_pool_size/' <<< "$MYSQLCONF")

# This will take the value that's assigned to the InnoDB Buffer Pool (should it exist) and store the value
INNODBVALUE=$(awk -F"=" '/innodb_buffer_pool_size/ {print $2}'i <<< "$MYSQLCONF")

# Grabs just the value for the buffer pool
[[ $INNODBVALUE =~ (([0-9]+)).*$ ]] &&
INNODBNUMVALUE=${BASH_REMATCH[1]} # Only the value

#Grabs just the alpha character denoting the memory denomination
[[ $INNODBVALUE =~ ([A-Za-z]).*$ ]] &&
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
[[ $MYISAMVALUE =~ (([0-9]+)).*$ ]] &&
MYISAMNUMVALUE=${BASH_REMATCH[1]} # Only the value

#Grabs just the alpha character denoting the memory denomination
[[ $MYISAMVALUE =~ ([A-Za-z]).*$ ]] &&
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


echo

echo "------------\\${PHPINFO} ${UNDERLINE}PHP INFO${RESET} \\----------------------------------"

echo


## Grab the version of PHP currently installed on the system
[[ $PHPVOUTPUT =~ (([0-9])\.([0-9])\.([0-9][0-9])).*$ ]] &&
PHPENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: x.x.xx
PHPMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: x
PHPMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: x
PHPBUILDVERSION=${BASH_REMATCH[4]}     # The build version #: xx

# Display the PHP version
echo "${PHPINFO}Version In Use:${RESET} $PHPENTIREVERSION"

# Quick check against a file that will verify if cPanel IS or is NOT installed. This is stored in a variable
CPANELTEST=$(cat /usr/local/cpanel/version 2>/dev/null)

# Check against that variable. If cPanel IS installed, run all the functions. If it's NOT installed, only run non-cPanel safe functions
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
[[ $PHPGLOBALCONF =~ (([0-9][0-9])).*$ ]] &&
PHPMEMLIMIT=${BASH_REMATCH[1]} # Only the value for the PHP memory_limit

[[ $PHPGLOBALCONF =~ ([A-Za-z]).*$ ]] &&
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
[[ $APACHEVERSION =~ (([0-9])\.([0-9])\.([0-9]+)).*$ ]] &&
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

# Determines if legacy cPanel backups are enabled
CPANELLEGACY=$(awk -F" " ' /BACKUPENABLE/ {print $2}' /etc/cpbackup.conf)

# Determines if the new cPanel backups are enabled
CPANELBACKUP=$(awk -F" " ' {gsub(/^[ \t]+|[ \t]+$/, "", $2)} /BACKUPENABLE/ {gsub( "['\'']","" ); print $2}' /var/cpanel/backups/config)

# This parses the cPanel version and breaks it down into the individual components of the version number with each part
# being stored as a separate variable. These individual components are not being utilized but provide the ability to
# easily compare the major / minor version numbers for version checking.

[[ $CPANELVERSION =~ (([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)).*$ ]] &&
CPANELENTIREVERSION=${BASH_REMATCH[1]} && # The whole version #: xx.xx.x.xx
CPANELMAJORVERSION=${BASH_REMATCH[2]} &&  # The major version #: xx
CPANELMINORVERSION=${BASH_REMATCH[3]} &&  # The minor version #: xx
CPANELBUILDVERSION=${BASH_REMATCH[4]} &&  # The build version #: x
CPANELREVISIONVERSION=${BASH_REMATCH[5]}   # The revision version #: xx


echo

echo "------------\\${CPANELINFO} ${UNDERLINE}CPANEL INFO${RESET} \\-------------------------------"

echo

echo "${CPANELINFO}Version In Use:${RESET} $CPANELVERSION"

echo "${CPANELINFO}Release Set To:${RESET} $CPANELRELEASE"

# Logic to review the status of the different backups systems to depending on if they're enabled or disabled
# display an appropriate message

if [ "$CPANELLEGACY" == "no" ] && [ "$CPANELBACKUP" == "no" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Disabled"

elif [ "$CPANELLEGACY" == "no" ] && [ "$CPANELBACKUP" == "yes" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Enabled"

elif [ "$CPANELLEGACY" == "yes" ] && [ "$CPANELBACKUP" == "no" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} Legacy Enabled"

elif [ "$CPANELLEGACY" == "yes" ] && [ "$CPANELBACKUP" == "yes" ]; then

        echo "${CPANELINFO}Backups Status:${RESET} BOTH Systems Enabled"

fi

}

##################################################################################
#                            END CPANEL INFO FUNCTION                            #
##################################################################################




##################################################################################
#                            BEGIN DISK INFO FUNCTION                            #
##################################################################################

# Function for all Disk Info related information
function diskinfo {

# Identify the BRAND of the RAID controller currently being used
RAIDBRAND=$(lspci 2>/dev/null | awk '/Adaptec|LSI/{for(i=1;i<=NF;++i)if($i~/Adaptec|LSI/)print $i}')

# The base information for the Adaptec cards
ADAPTECINFO=$(/usr/StorMan/arcconf getconfig 1 2>/dev/null)

# Identify the specific model of Adaptec card being used
ADAPTECMODEL=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Controller Model/ {print $2}' <<< "$ADAPTECINFO")

# Identify the current RAID level being implemented
ADAPTECRAID=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /RAID level/ {print $2}' <<< "$ADAPTECINFO")

# Count the number of devices / hard disks being used
ADAPTECDISKS=$(awk '/Device #/ {++c} END {print c}' <<< "$ADAPTECINFO")

# The base information for the LSI RAID
LSIINFO=$(/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aAll 2>/dev/null)

# The adapter information for the LSI / MegaRAID cards
LSIADAPTERINFO=$(/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aAll 2>/dev/null)

# The specific LSI / MegaSAS RAID controller model
LSIMODEL=$(awk -F ":" '/Product Name/ {print $2}' <<< "$LSIADAPTERINFO")


# Identifies how many drives / spans are involved with the RAID setup. This assists with calculating total # of disks
LSIDISKS=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Number Of Drives/ {print $2}' <<< "$LSIINFO")
LSISPANS=$(awk -F":" '{gsub(/^[ \t]+|[ \t]+$/, "", $2)} /Span/ {print $2}' <<< "$LSIINFO")

# Calculates the number of physical drives involved in the RAID setup
LSINUMBERDISKS=$((LSIDISKS * LSISPANS))

# This will show just "#" as the primary RAID level. Combined with how many spans are involved we can determine the
# actual RAID level (at least RAID 1 vs RAID 10)
LSIRAIDPRIMARY=$(awk -F"-" '/Primary/ {gsub(/,.*/,""); print $2}' <<< "$LSIINFO")



# I'm sure this could be better accomplished with some regex and more of it handled within Bash itself. For now this works
# and is extremely fast (not to mention it formats how I want). It stays. Will likely be reviewed at a later date.
DISKUSAGE=$(paste <(df -h | awk '{ $6=""; $7=""; print }' | column -t) <(df -hi | awk '{print substr($0, index($0, $5))}' | column -t))

echo

echo "------------\\${DISKINFO} ${UNDERLINE}DISK INFO${RESET} \\---------------------------------"

echo

echo "${DISKINFO}Disk Usage:${RESET}"

echo "$DISKUSAGE"

echo


# If there is no RAID card installed present "N/A" to indicate no RAID setup
if [[ "$RAIDBRAND" == "" ]];then

	echo "${DISKINFO}Controller:${RESET} N/A"

# If Adaptec is present, run the Adaptec commands and present the relevant information
elif [[ "$RAIDBRAND" == "Adaptec" ]];then

	echo "${DISKINFO}Controller:${RESET}" $ADAPTECMODEL

        echo "${DISKINFO}# of Disks:${RESET}" $ADAPTECDISKS

        echo "${DISKINFO}RAID Level:${RESET}" $ADAPTECRAID

# If LSI is present, run the MegaCLI commands and present the relevant information
elif [[ "$RAIDBRAND" == "LSI" ]];then

        echo "${DISKINFO}Controller:${RESET}" $LSIMODEL

        echo "${DISKINFO}# of Disks:${RESET}" $LSINUMBERDISKS

if [[ "$LSIRAIDPRIMARY" == "1" && "$LSISPANS" -gt "1" ]]; then

        echo "${DISKINFO}RAID Level:${RESET} 10"

elif [[ "$LSISPANS" == "1" ]];then

        echo "${DISKINFO}RAID Level:${RESET} 1"

else

        echo "${DISKINFO}Raid Level:${RESET} $LSIRAIDPRIMARY"

fi
fi

}

##################################################################################
#                              END DISK INFO FUNCTION                            #
##################################################################################


# Clear the screen
clear

# Display the header image
header_color

# Quick check against a file that will verify if Apache IS installed or is NOT installed. This is stored in a variable
APACHETEST=$(cat /etc/httpd/conf/httpd.conf 2>/dev/null)

# Quick check against a file that will verify if MySQL IS installed or is NOT installed. This is stored in a variable
MYSQLTEST=$(cat /etc/my.cnf 2>/dev/null)

PHPTEST=$(php -i 2>/dev/null | grep "Loaded Configuration File" | awk '{print $5}')

# Quick check against a file that will verify if cPanel IS or is NOT installed. This is stored in a variable
CPANELTEST=$(cat /usr/local/cpanel/version 2>/dev/null)

# Check against that variable. If cPanel IS installed, run all the functions. If it's NOT installed, only run non-cPanel safe functions
if [[ ! -z "$CPANELTEST" ]]; then
systeminfo
memoryinfo
diskinfo
phpinfo
cpanelinfo
apacheinfo
mysqlinfo

# If cPanel is NOT installed, check to see if  Apache, PHP, and MySQL ARE installed. If so, run Apache / PHP / MySQL safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]] && [[ ! -z "$MYSQLTEST" ]]; then
systeminfo
memoryinfo
diskinfo
phpinfo
apacheinfo
mysqlinfo

# If Apache and MySQL are NOT BOTH installed, check to see if Apache and PHP are installed. If they are, run Apache / PHP safe functions
elif [[ ! -z "$APACHETEST" ]] && [[ ! -z "$PHPTEST" ]]; then
systeminfo
memoryinfo
diskinfo
phpinfo
apacheinfo

# If Apache and PHP are NOT BOTH installed, check to see if JUST Apache is installed. If it is, run Apache safe functions
elif [[ ! -z "$APACHETEST" ]]; then
systeminfo
memoryinfo
diskinfo
apacheinfo

# If Apache and MySQL are not BOTH installed, and Apache is not installed, check for MySQL. If it is installed, run MySQL safe functions
elif [[ ! -z "$MYSQLTEST" ]]; then
systeminfo
memoryinfo
diskinfo
mysqlinfo

# If cPanel, Apache, and MySQL are NOT installed, run basic functions
systeminfo
memoryinfo
diskinfo

fi

echo
