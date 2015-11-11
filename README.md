# JSSBinarySelfHeal
JSS Binary Self Heal 

Overview of JSS Binary Self Heal

What do we do when computers stop communicating with the JSS?  The computer is in another city, state or country and I have no way to get my hands on this device today.  A Self Heal workflow can help repair the broken communication and get that computer talking to the JSS again.  This is an automated process to verify client to server communication and repair any detection of failure.

How this works

1. Uses a launch daemon that runs on a scheduled time each day that runs a script to perform a series of steps to verify that the computer is managed.
2. The script that is ran is performing the following taks:
    a. Does this computer have the JAMF binary
    b. Can this computer check the JSS connection
    c. Are we able to log this computers IP address to the JSS
    d. Are we able to execute a policy
    e. Is the MDM profile installed on this computer
3. Each computer that is using this Self Heal mechanism will have a local log that is tracking the verification checks.  These entries are logged with the current date and time the check was performed.
4. This log is then submitted ot the devices inventory record within the JSS

Caveats

Because this Self Heal workflow is using a quick add package, each time the Server is upgraded, we will need to make a new quickadd.  We will need to update the SelfHeal.sh file with the new quickadd invitation ID from the new quickadd we just made.  We can then push the SelfHeal.sh back out to our clients with the update.
