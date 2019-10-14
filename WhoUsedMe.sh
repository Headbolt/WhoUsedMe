#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#   This Script is designed for use in JAMF
#
#   - This script will ...
#       Look up the Users Display Name in Active Directory
#       Prefix the DisplayName with the current Date
#       Locate the Machines Object in Active Directory and update it's Description Field
#
###############################################################################################################################################
#
# Requires the following parameters be set.
#		DOMAIN=$4
#		USER=$5
#		PASS=$6
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.1 - 14/10/2019
#
#   - 13/09/2018 - V1.0 - Created by Headbolt
#
#   - 14/10/2019 - V1.1 - Updated by Headbolt
#                           More comprehensive error checking and notation
#
####################################################################################################
#
#   DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################
#
# Grabs the local User ID for the Logged in User JAMF pre-set variable #3
LUID=$3
# Grabs the NETBIOS name of the AD Domain that the users Machine Resides in from JAMF variable #4 eg. DOMAIN
DOMAIN=$4
# Grabs the Username of a user that has been granted specific permissions just for this task from JAMF variable #5 eg. username
# Recommended is Read/Write permissions ONLY to the Description Field of Descendant Computer Objects on the Relevant AD OU's 
USER=$5
# Grabs the Password of a user that has been granted specific permissions just for this task from JAMF variable #6 eg. password
PASS=$6
#
ScriptName="append prefix here as needed - Local Account Password Change"
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
# Outputting a Blank Line for Reporting Purposes
#/bin/echo
#
/bin/echo Ending Script '"'$ScriptName'"'
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
# Outputting a Dotted Line for Reporting Purposes
/bin/echo  -----------------------------------------------
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
####################################################################################################
#
# Outputs a blank line for reporting purposes
/bin/echo
#
SectionEnd
#
## Grab ComputerName
CompName=$(dsconfigad -show | awk '/Computer Account/{print $NF}' | sed 's/$$//')
#
## Look up Machine Object in AD read current Description String
ODstring=$(dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -read /Computers/${CompName}$ Comment)
#
## Strip out String to Just Get Description
OD=$(/bin/echo $ODstring | cut -c 10-) 
/bin/echo Current Machine Description = "$OD"
# Outputs a blank line for reporting purposes
/bin/echo
## Search AD For Users AD Object and Pull Out Display String
CNstring=$(dscl "/Active Directory/$DOMAIN/All Domains" -read /Users/$LUID dsAttrTypeNative:cn)
#
## Strip out String to Just Get Display Name
CN=$(/bin/echo $CNstring | cut -c 22-) 
#
if [ "$CN" == "" ]
	then
		/bin/echo 'Retrieval of AD Username Failed, Setting it to "Unknown" for this instance'
		# Outputs a blank line for reporting purposes
		/bin/echo
		CN="Unknown"
fi
#
## Get Current Date, formatted the way we want, and append Users Display Name
## This gives us the Description we want to put into AD
ND=$(date "+%Y/%m/%d - $CN")
#
/bin/echo AD User Display Name = $CN
#
# Outputs a blank line for reporting purposes
/bin/echo
/bin/echo New Description to Write = $ND
#
# Outputs a blank line for reporting purposes
/bin/echo
/bin/echo Computername = $CompName
#
SectionEnd
#
## Check if Description is Currently Blank
## If it is then Add the Description
## If not, then replace the current description with the new one
#
if [ "$OD" == "" ]
	then
		/bin/echo Adding Description
		dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -merge /Computers/${CompName}$ Comment "$ND"
	else
		/bin/echo Updating Description
		dscl -u $USER -P $PASS "/Active Directory/$DOMAIN/All Domains" -change /Computers/${CompName}$ Comment "$OD" "$ND"
fi
#
SectionEnd
ScriptEnd
