#!/bin/bash
#
#   TITLE: Inspector Gadget
#  AUTHOR: michael mcdonald
# CONTACT: michael@liquidweb.com
# VERSION: 0.1
# PURPOSE: this will inspect various aspects of a given system
#          as specified / requested by the user.

#######################################################################################

################################
#        COLOR VARIABLES       #
################################

# The colors defined throughout the script 

ORANGE=$(tput setaf 202)
YELLOW=$(tput setaf 226)
RESET=$(tput sgr0)


# Clear the screen to start nice and fresh

clear


# The header display function (color version; not sure if I'm going to make a bnw version)

function header_color {

echo " ${ORANGE} ___                           _             "
echo " |_ _|_ __  ___ _ __   ___  ___| |_ ___  _ __           "
echo "  | || '_ \/ __| '_ \ / _ \/ __| __/ _ \| '__|          "
echo "  | || | | \__ \ |_) |  __/ (__| || (_) | |             "
echo " |___|_| |_|___/ .__/ \___|\___|\__\___/|_|${RESET}             "
echo " ${YELLOW}  ____${RESET}        ${ORANGE}|_|${RESET}${YELLOW}_            _       ${RESET} _       " 
echo " ${YELLOW} / ___| __ _  __| | __ _  ___| |_     ${RESET}/ \              "
echo " ${YELLOW}| |  _ / _\` |/ _\` |/ _\` |/ _ \ __|    ${RESET}\_/              "
echo " ${YELLOW}| |_| | (_| | (_| | (_| |  __/ |_    ${RESET} /                "
echo " ${YELLOW} \____|\__,_|\__,_|\__, |\___|\__| ${RESET}  /  v1.0           "
echo " ${YELLOW}                   |___/ ${RESET}      "
}


# Display the header_color function

header_color

# Give a blank line after the header

echo 

################################
#        MORE VARIABLES        #
################################

CENTOSVERSION_OLD=$(cat /etc/redhat-release 2>/dev/null | sed 's/Linux//g' | awk '{print $3}' | cut -d "." -f 1)
CENTOSVERSION=$(cat /etc/redhat-release 2>/dev/null)

printf "$CENTOSVERSION" [0-9]\.[0-9]

echo
