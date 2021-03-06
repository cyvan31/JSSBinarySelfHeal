#!/bin/sh

#####################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#####################################################################################################
#
#       This script is designed to perform a self heal on the client.  If the client does not have
#		    the JAMF Binary, a quickadd package is downloaded and installed.  If the client cannot
#		    check in with the JSS, run a policy, or cannot log it's IP address, the client
#		    will be enrolled via invitation.  If the MDM profile is not found on the device, the client
#       will get re-enrolled into MDM.
#
#		    This process will work on a 9.81 JSS, this will not work on any JSS version pre 9.8.
#
#####################################################################################################
#
#       version 1.0 by Lucas Vance
#       This script will only work with a 9.8+ JSS
#
#####################################################################################################

####################### Variables ################################
jssUrl="" # ex. https://jamit.q.jamfsw.corp:8443
enrollInv="" # Invitation ID from a quickadd package
logFile="/Users/Shared/enrollLog.log"
check=`/usr/local/bin/jamf checkJSSConnection | grep "The JSS is available"`
quickLocation="/tmp/quickadd.zip"
log=`/usr/local/bin/jamf log`
policy=`/usr/local/bin//jamf policy -event heal`
mdmEnrollmentProfileID="00000000-0000-0000-A000-4A414D460003"
enrolled=`/usr/bin/profiles -P | /usr/bin/grep "$mdmEnrollmentProfileID"`

addDate(){
	while IFS= read -r line; do
		echo "$(date) $line"
	done
}

######################## Do Not Modify Below This Line ####################################

# Create enrollLog if it doesn't exisit
if [[ ! -f $logFile ]];
	then echo "Creating enrollLog.log ....." | addDate >> $logFile;
	touch $logFile | addDate >> $logFile;
	sleep 5;
else echo "enrollLog.log already exists ..." | addDate >> $logFile;
fi

# Check to see if binary exists if not install it, if not, install the binary and eroll the client
if [[ ! -f /usr/local/jamf/bin/jamf ]];
	then echo "Downloading the quickadd package from the JSS ...." | addDate >> $logFile;
		curl -sk $jssUrl/quickadd.zip > $quickLocation | addDate >> $logFile;
		echo "Download is complete ... Unpacking the quickadd package installer to /tmp/" | addDate >> $logFile;
		unzip /tmp/quickadd.zip -d /tmp/ | addDate >> $logFile;
		echo "Unzip is complete, now installing the JSS Binary" | addDate >> $logFile;
		/usr/sbin/installer -dumplog -verbose -pkg /tmp/QuickAdd.pkg -target / | addDate >> $logFile;
		echo "Installation is complete, the client should now be enrolled into the JSS" | addDate >> $logFile;
		echo "Cleaning up quickadd package ....." | addDate >> $logFile;
		rm -f /tmp/quickadd.zip | addDate >> $logFile;
		rm -rf /tmp/QuickAdd.pkg | addDate >> $logFile;
		rm -rf /tmp/_* | addDate >> $logFile;
	else echo "JAMF binary is installed .... nothing to do" | addDate >> $logFile;
fi

# Check to see if the client to check in with the JSS, if not, enroll the client
if [[ ${check} =~ "The JSS is available" ]];
	then echo "Client can successfully check in with the JSS" | addDate >> $logFile;
	else jamf createConf -k -url $jssUrl | addDate >> $logFile;
	/usr/local/bin/jamf enroll -invitation $enrollInv | addDate >> $logFile;
fi

# Can the client log it's IP address with the JSS, if not, enroll the client
if [[ ${log} =~ "Logging to $jssUrl/..." ]];
	then echo "Client can log IP address with JSS" | addDate >> $logFile
	else jamf createConf -k -url $jssUrl | addDate >> $logFile;
	/usr/local/bin/jamf enroll -invitation $enrollInv | addDate >> $logFile;
fi

# Can the client execute a policy, if not, enroll the client
if [[ ${policy} =~ "heal" ]];
	then echo "Client can execute policies at this time" | addDate >> $logFile;
	else jamf createConf -k -url $jssUrl | addDate >> $logFile;
	/usr/local/bin/jamf enroll -invitation $enrollInv | addDate >> $logFile;
fi

# Does the client have it's MDM profile, if not, issue it to the client
if [[ "$enrolled" != "" ]]; 
	then echo "Client is enrolled with MDM" | addDate >> $logFile;
	else echo "This client is not enrolled with MDM, enrolling now ....." | addDate >> $logFile;
	/usr/local/bin/jamf mdm | addDate >> $logFile;
fi
